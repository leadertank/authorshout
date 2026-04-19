module Payments
	class PaypalWebhookVerifier
		class Error < StandardError; end

		class << self
			attr_accessor :test_result
		end

		def initialize(client: Payments::PaypalHttpClient.new, config: Payments::PaypalConfig.new)
			@client = client
			@config = config
		end

		def verify(headers:, event:)
			return self.class.test_result unless self.class.test_result.nil?

			response = client.post(
				"/v1/notifications/verify-webhook-signature",
				{
					auth_algo: headers["PayPal-Auth-Algo"],
					cert_url: headers["PayPal-Cert-Url"],
					transmission_id: headers["PayPal-Transmission-Id"],
					transmission_sig: headers["PayPal-Transmission-Sig"],
					transmission_time: headers["PayPal-Transmission-Time"],
					webhook_id: webhook_id,
					webhook_event: event
				}
			)

			response["verification_status"] == "SUCCESS"
		end

		private

		attr_reader :client, :config

		def webhook_id
			config.fetch!("PAYPAL_WEBHOOK_ID")
		end
	end
end