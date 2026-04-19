require "net/http"
require "json"

module Payments
	class PaypalHttpClient
		class Error < StandardError; end

		def get(path)
			request = Net::HTTP::Get.new(path)
			perform(request)
		end

		def post(path, payload)
			request = Net::HTTP::Post.new(path)
			request.body = payload.to_json
			request["Content-Type"] = "application/json"
			perform(request)
		end

		private

		def perform(request)
			request["Authorization"] = "Bearer #{access_token}"
			response = http.request(request)
			parsed = JSON.parse(response.body.presence || "{}")
			return parsed if response.is_a?(Net::HTTPSuccess) || response.is_a?(Net::HTTPCreated)

			raise Error, parsed["message"].presence || "PayPal request failed with status #{response.code}"
		end

		def access_token
			@access_token ||= begin
				request = Net::HTTP::Post.new("/v1/oauth2/token")
				request.basic_auth(paypal_client_id, paypal_client_secret)
				request.set_form_data(grant_type: "client_credentials")
				response = http.request(request)
				parsed = JSON.parse(response.body.presence || "{}")
				raise Error, parsed["error_description"].presence || "Unable to authenticate with PayPal" unless response.is_a?(Net::HTTPSuccess)

				parsed.fetch("access_token")
			end
		end

		def http
			@http ||= begin
				connection = Net::HTTP.new(base_uri.host, base_uri.port)
				connection.use_ssl = true
				connection
			end
		end

		def base_uri
			@base_uri ||= URI(paypal_env == "live" ? "https://api-m.paypal.com" : "https://api-m.sandbox.paypal.com")
		end

		def paypal_client_id
			ENV.fetch("PAYPAL_CLIENT_ID")
		end

		def paypal_client_secret
			ENV.fetch("PAYPAL_CLIENT_SECRET")
		end

		def paypal_env
			ENV.fetch("PAYPAL_ENV", "sandbox")
		end
	end
end