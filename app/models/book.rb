class Book < ApplicationRecord
  ALLOWED_IMAGE_CONTENT_TYPES = %w[image/png image/jpeg image/jpg].freeze
  MAX_IMAGE_FILE_SIZE = 2.megabytes

  belongs_to :profile, optional: true
  has_many :book_likes, dependent: :destroy
  has_one_attached :cover_image

  validates :title, presence: true, length: { maximum: 180 }
  validates :purchase_url, presence: true
  validate :purchase_url_must_be_valid
  validate :cover_image_url_must_be_valid
  validate :cover_image_must_be_png_or_jpg_under_size_limit

  # Only delegate user if profile is present
  delegate :user, to: :profile, allow_nil: true

  # Scope for admin-submitted books
  scope :admin_submitted, -> { where(admin_submitted: true) }
  scope :member_submitted, -> { where(admin_submitted: false) }

  def total_likes
    likes_count || 0
  end

  def liked_by?(user: nil, visitor_token: nil)
    if user.present?
      return book_likes.any? { |like| like.user_id == user.id } if association(:book_likes).loaded?

      book_likes.exists?(user_id: user.id)
    elsif visitor_token.present?
      return book_likes.any? { |like| like.visitor_token == visitor_token } if association(:book_likes).loaded?

      book_likes.exists?(visitor_token: visitor_token)
    else
      false
    end
  end

  def cover_image_source
    return cover_image if cover_image.attached?
    return cover_image_url if cover_image_url.present?
    nil
  end

  def submitted_by_admin?
    admin_submitted
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

  def cover_image_must_be_png_or_jpg_under_size_limit
    return unless cover_image.attached?

    unless ALLOWED_IMAGE_CONTENT_TYPES.include?(cover_image.blob.content_type)
      errors.add(:cover_image, "must be a .png or .jpg image")
    end

    if cover_image.blob.byte_size > MAX_IMAGE_FILE_SIZE
      errors.add(:cover_image, "must be 2MB or smaller")
    end
  end
end
