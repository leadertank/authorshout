module Webhooks
	class PaypalController < ActionController::Base
		skip_forgery_protection

		def create
			payload = JSON.parse(request.raw_post)
			verified = Payments::PaypalWebhookVerifier.new.verify(headers: request.headers, event: payload)
			return head :unauthorized unless verified

			Payments::PaypalWebhookProcessor.new(payload: payload).call
			head :ok
		rescue JSON::ParserError
			head :bad_request
		rescue Payments::PaypalHttpClient::Error, Payments::PaypalWebhookVerifier::Error => error
			Rails.logger.error("PayPal webhook error: #{error.message}")
			head :unprocessable_entity
		end
	end
end