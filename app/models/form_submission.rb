class FormSubmission < ApplicationRecord
	belongs_to :form
	belongs_to :user, optional: true
	has_many :form_payment_events, dependent: :destroy

	enum :status, { pending: 0, completed: 1, canceled: 2, failed: 3 }, default: :pending
	enum :payment_status, { not_required: 0, payment_pending: 1, paid: 2, payment_failed: 3, payment_canceled: 4 }, default: :not_required

	validates :public_token, presence: true, uniqueness: true

	before_validation :assign_public_token, on: :create

	def payload
		JSON.parse(payload_json.presence || "{}")
	rescue JSON::ParserError
		{}
	end

	def payload=(value)
		self.payload_json = value.to_json
	end

	def mark_completed!(payment_reference: nil, customer_reference: nil)
		update!(
			status: :completed,
			payment_status: form.requires_payment? ? :paid : :not_required,
			payment_reference: payment_reference.presence || self.payment_reference,
			provider_customer_reference: customer_reference.presence || self.provider_customer_reference,
			paid_at: form.requires_payment? ? Time.current : paid_at,
			submitted_at: submitted_at || Time.current
		)
	end

	private

	def assign_public_token
		self.public_token ||= SecureRandom.hex(16)
	end
end