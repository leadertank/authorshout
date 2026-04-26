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
end
