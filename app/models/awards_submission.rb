class AwardsSubmission < ApplicationRecord
  DEFAULT_FORM_KEY = "8th-annual-author-shout-book-awards"
  FORM_LABELS = {
    DEFAULT_FORM_KEY => "8th Annual Author Shout Book Awards"
  }.freeze

  enum :payment_status, {
    pending: 0,
    paid: 1,
    failed: 2
  }, default: :pending

  before_validation :ensure_public_token
  before_validation :ensure_form_key

  validates :first_name, presence: true, length: { maximum: 120 }
  validates :last_name, presence: true, length: { maximum: 120 }
  validates :author_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :book_title, presence: true, length: { maximum: 220 }
  validates :book_url, presence: true

  validate :book_url_must_be_valid
  validate :website_url_must_be_valid
  validate :x_url_must_be_valid
  validate :facebook_url_must_be_valid
  validate :instagram_url_must_be_valid

  scope :most_recent_first, -> { order(created_at: :desc) }
  scope :for_form, ->(form_key) { where(form_key: form_key) }

  def submitter_name
    "#{first_name} #{last_name}".strip
  end

  def form_label
    FORM_LABELS.fetch(form_key, form_key.to_s.humanize)
  end

  private

  def ensure_public_token
    return if public_token.present?

    self.public_token = SecureRandom.hex(12)
  end

  def ensure_form_key
    self.form_key = DEFAULT_FORM_KEY if form_key.blank?
  end

  def validate_optional_url(attribute)
    value = public_send(attribute)
    return if value.blank?

    parse_http_url!(value)
  rescue URI::InvalidURIError, TypeError
    errors.add(attribute, "must be a valid URL")
  end

  def parse_http_url!(value)
    uri = URI.parse(value)
    return if uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)

    raise URI::InvalidURIError, "invalid URL"
  end

  def book_url_must_be_valid
    parse_http_url!(book_url)
  rescue URI::InvalidURIError, TypeError
    errors.add(:book_url, "must be a valid URL")
  end

  def website_url_must_be_valid
    validate_optional_url(:website_url)
  end

  def x_url_must_be_valid
    validate_optional_url(:x_url)
  end

  def facebook_url_must_be_valid
    validate_optional_url(:facebook_url)
  end

  def instagram_url_must_be_valid
    validate_optional_url(:instagram_url)
  end
end
