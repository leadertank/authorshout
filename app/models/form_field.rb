class FormField < ApplicationRecord
	FIELD_TYPES = %w[text email textarea select radio checkbox number date].freeze
	WIDTHS = [12, 6, 4].freeze

	belongs_to :form

	validates :label, :identifier, :field_type, presence: true
	validates :field_type, inclusion: { in: FIELD_TYPES }
	validates :identifier, format: { with: /\A[a-z0-9_]+\z/ }
	validates :identifier, uniqueness: { scope: :form_id }
	validates :width, inclusion: { in: WIDTHS }
	validate :options_required_for_choice_fields

	before_validation :normalize_identifier

	def options
		options_text.to_s.lines.map(&:strip).reject(&:blank?)
	end

	def choice_field?
		%w[select radio checkbox].include?(field_type)
	end

	def multi_value?
		field_type == "checkbox" && options.any?
	end

	private

	def normalize_identifier
		base_value = identifier.presence || label
		self.identifier = base_value.to_s.parameterize(separator: "_") if base_value.present?
	end

	def options_required_for_choice_fields
		return unless choice_field?
		return if options.any?

		errors.add(:options_text, "must include at least one option")
	end
end