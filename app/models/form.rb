class Form < ApplicationRecord
	has_many :form_fields, -> { order(:position, :created_at) }, dependent: :destroy, inverse_of: :form
	has_many :form_submissions, -> { order(created_at: :desc) }, dependent: :destroy

	accepts_nested_attributes_for :form_fields, allow_destroy: true

	enum :status, { draft: 0, published: 1 }, default: :draft
	enum :payment_mode, { free: 0, one_time: 1, subscription: 2 }, default: :free

	validates :title, :slug, :submit_button_text, :currency, :payment_provider, presence: true
	validates :slug, uniqueness: true
	validates :payment_provider, inclusion: { in: %w[paypal] }
	validates :currency, length: { is: 3 }
	validates :amount_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
	validates :billing_interval, inclusion: { in: %w[day week month year] }, if: :subscription?
	validates :provider_plan_id, presence: true, if: :subscription?
	validate :amount_required_for_paid_forms
	validate :at_least_one_active_field

	before_validation :generate_slug, if: -> { title.present? && slug.blank? }
	before_validation :normalize_slug
	before_validation :normalize_currency

	scope :live, -> { published }
	scope :search_query, ->(query) {
		where("forms.title LIKE :query OR forms.slug LIKE :query OR forms.description LIKE :query", query: "%#{sanitize_sql_like(query.to_s.strip)}%")
	}

	def to_param
		slug
	end

	def content_state_label
		published? ? "Live" : "Draft"
	end

	def requires_payment?
		!free?
	end

	def payment_mode_label
		payment_mode.humanize
	end

	def formatted_amount
		format("%<currency>s %<amount>.2f", currency: currency, amount: amount_cents.to_i / 100.0)
	end

	def active_fields
		form_fields.reject(&:marked_for_destruction?)
	end

	private

	def generate_slug
		self.slug = title.to_s.parameterize
	end

	def normalize_slug
		self.slug = slug.to_s.parameterize if slug.present?
	end

	def normalize_currency
		self.currency = currency.to_s.upcase if currency.present?
	end

	def amount_required_for_paid_forms
		return unless requires_payment?
		return if amount_cents.to_i.positive?

		errors.add(:amount_cents, "must be greater than zero for paid forms")
	end

	def at_least_one_active_field
		return if active_fields.any?

		errors.add(:base, "Add at least one field to the form")
	end
end