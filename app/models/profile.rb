class Profile < ApplicationRecord
  belongs_to :user
  has_one :book, dependent: :destroy
  has_one_attached :avatar

  accepts_nested_attributes_for :book, update_only: true
  accepts_nested_attributes_for :user, update_only: true

  validates :bio, length: { maximum: 1200 }
  validate :avatar_url_must_be_valid

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

  def avatar_url_must_be_valid
    return if avatar_url.blank?

    uri = URI.parse(avatar_url)
    return if uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)

    errors.add(:avatar_url, "must be a valid URL")
  rescue URI::InvalidURIError, TypeError
    errors.add(:avatar_url, "must be a valid URL")
  end
end
