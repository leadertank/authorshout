module Payments
	class FormCheckoutReadiness
		PLACEHOLDER_PREFIXES = %w[REPLACE_ CHANGE_ME].freeze

		def initialize(form, config: Payments::PaypalConfig.new)
			@form = form
			@config = config
		end

		def ready?
			messages.empty?
		end

		def messages
			@messages ||= begin
				items = []
				return items unless form.requires_payment?

				unless form.payment_provider == "paypal"
					items << "Unsupported payment provider configured for this form."
					return items
				end

				if config.missing_keys.any?
					items << "Missing PayPal credentials: #{config.missing_keys.join(", ")}."
				end

				if form.subscription? && placeholder_plan_id?
					items << "Replace the placeholder PayPal plan ID before testing subscription checkout."
				end

				items
			end
		end

		private

		attr_reader :form, :config

		def placeholder_plan_id?
			plan_id = form.provider_plan_id.to_s.strip
			return true if plan_id.blank?

			PLACEHOLDER_PREFIXES.any? { |prefix| plan_id.start_with?(prefix) }
		end
	end
end