module Forms
	class SubmissionBuilder
		Result = Struct.new(:submission, :errors, keyword_init: true) do
			def success?
				errors.empty?
			end
		end

		EMAIL_REGEX = URI::MailTo::EMAIL_REGEXP

		def initialize(form:, params:, user: nil)
			@form = form
			@params = params.to_h
			@user = user
		end

		def call
			payload = {}
			errors = []

			form.form_fields.each do |field|
				value = extract_value(field)
				field_errors = validate_field(field, value)
				errors.concat(field_errors)
				payload[field.identifier] = normalize_value(field, value)
			end

			submission = form.form_submissions.build(
				user: user,
				submitter_email: inferred_submitter_email(payload),
				payment_provider: form.requires_payment? ? form.payment_provider : nil,
				status: form.requires_payment? ? :pending : :completed,
				payment_status: form.free? ? :not_required : :payment_pending,
				submitted_at: form.free? ? Time.current : nil
			)
			submission.payload = payload

			if errors.empty?
				submission.paid_at = Time.current if form.free?
				Result.new(submission:, errors: [])
			else
				Result.new(submission:, errors:)
			end
		end

		private

		attr_reader :form, :params, :user

		def extract_value(field)
			if field.multi_value?
				Array(params[field.identifier]).reject(&:blank?)
			else
				params[field.identifier]
			end
		end

		def normalize_value(field, value)
			return value if field.multi_value?

			value.to_s.strip
		end

		def validate_field(field, value)
			errors = []
			blank = field.multi_value? ? value.blank? : value.to_s.strip.blank?
			errors << "#{field.label} is required" if field.required? && blank
			return errors if blank

			case field.field_type
			when "email"
				errors << "#{field.label} must be a valid email" unless value.to_s.match?(EMAIL_REGEX)
			when "number"
				errors << "#{field.label} must be a number" unless value.to_s.match?(/\A-?\d+(\.\d+)?\z/)
			when "select", "radio"
				errors << "#{field.label} has an invalid option" unless field.options.include?(value.to_s)
			when "checkbox"
				if field.options.any?
					invalid_values = Array(value) - field.options
					errors << "#{field.label} has an invalid option" if invalid_values.any?
				elsif field.required? && value != "1"
					errors << "#{field.label} must be checked"
				end
			end

			errors
		end

		def inferred_submitter_email(payload)
			email_field = form.form_fields.find { |field| field.field_type == "email" }
			return unless email_field

			payload[email_field.identifier].to_s
		end
	end
end