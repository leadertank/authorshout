module Payments
	class PaypalWebhookProcessor
		Result = Struct.new(:status, :submission, :event, keyword_init: true)

		SUCCESS_EVENTS = %w[
			CHECKOUT.ORDER.APPROVED
			CHECKOUT.ORDER.COMPLETED
			PAYMENT.CAPTURE.COMPLETED
			BILLING.SUBSCRIPTION.ACTIVATED
			BILLING.SUBSCRIPTION.RE-ACTIVATED
			BILLING.SUBSCRIPTION.PAYMENT.COMPLETED
		].freeze

		FAILURE_EVENTS = %w[
			PAYMENT.CAPTURE.DENIED
			PAYMENT.CAPTURE.DECLINED
			BILLING.SUBSCRIPTION.PAYMENT.FAILED
		].freeze

		CANCELED_EVENTS = %w[
			BILLING.SUBSCRIPTION.CANCELLED
			BILLING.SUBSCRIPTION.SUSPENDED
			BILLING.SUBSCRIPTION.EXPIRED
		].freeze

		def initialize(payload:)
			@payload = payload
		end

		def call
			submission = find_submission
			return Result.new(status: :ignored) unless submission

			event = persist_event(submission)
			apply_state_change(submission)

			Result.new(status: :processed, submission:, event:)
		end

		private

		attr_reader :payload

		def resource
			payload.fetch("resource", {})
		end

		def event_type
			payload["event_type"].to_s
		end

		def find_submission
			by_public_token || by_payment_reference
		end

		def by_public_token
			tokens = [
				resource["custom_id"],
				resource.dig("purchase_units", 0, "custom_id"),
				resource.dig("supplementary_data", "related_ids", "custom_id")
			].compact_blank.uniq

			FormSubmission.find_by(public_token: tokens) if tokens.any?
		end

		def by_payment_reference
			references = [
				resource["id"],
				resource["billing_agreement_id"],
				resource.dig("supplementary_data", "related_ids", "order_id"),
				resource.dig("supplementary_data", "related_ids", "subscription_id")
			].compact_blank.uniq

			FormSubmission.find_by(payment_reference: references) if references.any?
		end

		def persist_event(submission)
			event = submission.form_payment_events.find_or_initialize_by(
				provider: "paypal",
				event_type: event_type,
				external_id: payload["id"].presence || resource["id"].presence || submission.payment_reference
			)
			event.status = resource["status"].presence || event_type
			event.payload = payload
			event.processed_at = Time.current
			event.save!
			event
		end

		def apply_state_change(submission)
			if SUCCESS_EVENTS.include?(event_type)
				submission.mark_completed!(payment_reference: resolved_payment_reference, customer_reference: resolved_customer_reference)
			elsif FAILURE_EVENTS.include?(event_type)
				submission.mark_payment_failed!(payment_reference: resolved_payment_reference)
			elsif CANCELED_EVENTS.include?(event_type)
				submission.mark_payment_canceled!(payment_reference: resolved_payment_reference)
			end
		end

		def resolved_payment_reference
			resource["id"].presence || resource["billing_agreement_id"].presence || resource.dig("supplementary_data", "related_ids", "subscription_id") || resource.dig("supplementary_data", "related_ids", "order_id")
		end

		def resolved_customer_reference
			resource.dig("payer", "email_address") || resource.dig("subscriber", "email_address")
		end
	end
end