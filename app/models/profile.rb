class Profile < ApplicationRecord
  URL_FIELDS = %i[
    avatar_url
    website
    x_url
    facebook_url
    instagram_url
    threads_url
    bluesky_url
    youtube_url
  ].freeze

  belongs_to :user
  has_many :books, dependent: :destroy
  has_one_attached :avatar

  accepts_nested_attributes_for :books, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :user, update_only: true

  validates :bio, length: { maximum: 1200 }
  validate :public_urls_must_be_valid
  validate :book_limit_for_plan

  def avatar_image_source
    return avatar if avatar.attached?
    return avatar_url if avatar_url.present?

    nil
  end

  def social_links
    {
      "X" => x_url,
      "Facebook" => facebook_url,
      "Instagram" => instagram_url,
      "Threads" => threads_url,
      "Bluesky" => bluesky_url,
      "YouTube" => youtube_url
    }.select { |_, value| value.present? }
  end

  def to_param
    name_slug = [ user.first_name, user.last_name ].join("-").parameterize
    return name_slug if name_slug.present?

    user.display_name.to_s.parameterize.presence || id.to_s
  end

  private

  def public_urls_must_be_valid
    URL_FIELDS.each do |field|
      value = public_send(field)
      next if value.blank?

      uri = URI.parse(value)
      next if uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)

      errors.add(field, "must be a valid URL")
    rescue URI::InvalidURIError, TypeError
      errors.add(field, "must be a valid URL")
    end
  end

  def book_limit_for_plan
    return if user.blank? || user.paid_member?

    remaining_books = books.reject(&:marked_for_destruction?)
    return if remaining_books.size <= 1

    errors.add(:books, "Free plan allows 1 book. Upgrade to PAID for unlimited books.")
  end
end
