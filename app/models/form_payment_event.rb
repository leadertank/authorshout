class FormPaymentEvent < ApplicationRecord
	belongs_to :form_submission

	validates :provider, :event_type, :processed_at, presence: true

	def payload
		JSON.parse(payload_json.presence || "{}")
	rescue JSON::ParserError
		{}
	end

	def payload=(value)
		self.payload_json = value.to_json
	end
end