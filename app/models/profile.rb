class Profile < ApplicationRecord
  ALLOWED_IMAGE_CONTENT_TYPES = %w[image/png image/jpeg image/jpg].freeze
  MAX_IMAGE_FILE_SIZE = 2.megabytes

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

  accepts_nested_attributes_for :books, allow_destroy: true, reject_if: :reject_blank_new_book?
  accepts_nested_attributes_for :user, update_only: true

  validates :bio, length: { maximum: 1200 }
  validate :public_urls_must_be_valid
  validate :book_limit_for_plan
  validate :featured_book_limit
  validate :avatar_must_be_png_or_jpg_under_size_limit

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

  def featured_book_limit
    return if user.blank?

    remaining_books = books.reject(&:marked_for_destruction?)
    featured_count = remaining_books.count(&:featured?)

    eligible_for_featured = user.paid_member? || user.featured_author?
    return unless eligible_for_featured

    return if featured_count <= 1

    errors.add(:books, "You can feature only 1 book at a time.")
  end

  def reject_blank_new_book?(attributes)
    return false if ActiveModel::Type::Boolean.new.cast(attributes["_destroy"] || attributes[:_destroy])
    return false if (attributes["id"] || attributes[:id]).present?

    title = attributes["title"] || attributes[:title]
    purchase_url = attributes["purchase_url"] || attributes[:purchase_url]
    cover_image_url = attributes["cover_image_url"] || attributes[:cover_image_url]
    cover_image = attributes["cover_image"] || attributes[:cover_image]

    title.blank? && purchase_url.blank? && cover_image_url.blank? && cover_image.blank?
  end

  def avatar_must_be_png_or_jpg_under_size_limit
    return unless avatar.attached?

    unless ALLOWED_IMAGE_CONTENT_TYPES.include?(avatar.blob.content_type)
      errors.add(:avatar, "must be a .png or .jpg image")
    end

    if avatar.blob.byte_size > MAX_IMAGE_FILE_SIZE
      errors.add(:avatar, "must be 2MB or smaller")
    end
  end
end
