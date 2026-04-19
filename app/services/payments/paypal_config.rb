module Payments
	class PaypalConfig
		REQUIRED_KEYS = %w[PAYPAL_CLIENT_ID PAYPAL_CLIENT_SECRET].freeze

		def configured?
			missing_keys.empty?
		end

		def missing_keys
			REQUIRED_KEYS.select { |key| ENV[key].to_s.strip.blank? }
		end

		def environment
			ENV.fetch("PAYPAL_ENV", "sandbox")
		end

		def sandbox?
			environment == "sandbox"
		end

		def live?
			environment == "live"
		end

		def fetch!(key)
			value = ENV[key].to_s.strip
			raise Payments::PaypalHttpClient::Error, "Missing PayPal configuration: #{key}" if value.blank?

			value
		end
	end
end