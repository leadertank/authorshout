require "net/http"
require "json"
require "ostruct"

module Payments
	class PaypalGateway
		class Error < StandardError; end

		def initialize(client: Payments::PaypalHttpClient.new)
			@client = client
		end

		def start_checkout(form:, submission:, return_url:, cancel_url:)
			response = form.one_time? ? create_order(form, submission, return_url, cancel_url) : create_subscription(form, submission, return_url, cancel_url)
			approval_url = Array(response["links"]).find { |link| link["rel"] == "approve" }.to_h["href"]
			raise Error, "PayPal did not return an approval URL" if approval_url.blank?

			OpenStruct.new(approval_url:, external_id: response["id"], payload: response)
		end

		def finalize_checkout(form:, submission:, params:)
			if form.one_time?
				order_id = params[:token].to_s
				response = client.post("/v2/checkout/orders/#{order_id}/capture", {})
				status = response["status"].to_s
				paid = status == "COMPLETED"
				OpenStruct.new(paid:, external_id: order_id, customer_reference: payer_email(response), payload: response, status:)
			else
				subscription_id = params[:token].presence || params[:subscription_id].presence
				response = client.get("/v1/billing/subscriptions/#{subscription_id}")
				status = response["status"].to_s
				paid = %w[ACTIVE APPROVAL_PENDING].include?(status)
				OpenStruct.new(paid:, external_id: subscription_id, customer_reference: response.dig("subscriber", "email_address"), payload: response, status:)
			end
		end

		private

		attr_reader :client

		def create_order(form, submission, return_url, cancel_url)
			client.post(
				"/v2/checkout/orders",
				{
					intent: "CAPTURE",
					purchase_units: [
						{
							reference_id: submission.public_token,
							custom_id: submission.public_token,
							amount: {
								currency_code: form.currency,
								value: format("%.2f", form.amount_cents.to_i / 100.0)
							},
							description: form.title
						}
					],
					application_context: {
						return_url: return_url,
						cancel_url: cancel_url,
						user_action: "PAY_NOW"
					}
				}
			)
		end

		def create_subscription(form, submission, return_url, cancel_url)
			client.post(
				"/v1/billing/subscriptions",
				{
					plan_id: form.provider_plan_id,
					custom_id: submission.public_token,
					application_context: {
						return_url: return_url,
						cancel_url: cancel_url
					}
				}
			)
		end

		def payer_email(response)
			response.dig("payer", "email_address") || response.dig("payment_source", "paypal", "email_address")
		end
	end
end