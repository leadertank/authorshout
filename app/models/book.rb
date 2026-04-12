class Book < ApplicationRecord
  belongs_to :profile
  has_many :book_likes, dependent: :destroy
  has_one_attached :cover_image

  validates :title, presence: true, length: { maximum: 180 }
  validates :purchase_url, presence: true
  validate :purchase_url_must_be_valid
  validate :cover_image_url_must_be_valid

  delegate :user, to: :profile

  def total_likes
    likes_count || 0
  end

  def cover_image_source
    return cover_image if cover_image.attached?
    return cover_image_url if cover_image_url.present?

    nil
  end

  private

  def purchase_url_must_be_valid
    uri = URI.parse(purchase_url)
    return if uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)

    errors.add(:purchase_url, "must be a valid URL")
  rescue URI::InvalidURIError, TypeError
    errors.add(:purchase_url, "must be a valid URL")
  end

  def cover_image_url_must_be_valid
    return if cover_image_url.blank?

    uri = URI.parse(cover_image_url)
    return if uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)

    errors.add(:cover_image_url, "must be a valid URL")
  rescue URI::InvalidURIError, TypeError
    errors.add(:cover_image_url, "must be a valid URL")
  end
end
