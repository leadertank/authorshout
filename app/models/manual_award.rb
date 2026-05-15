class ManualAward < ApplicationRecord
  ALLOWED_IMAGE_CONTENT_TYPES = %w[image/png image/jpeg image/jpg].freeze
  MAX_IMAGE_FILE_SIZE = 2.megabytes

  enum :primary_page, {
    top_picks_page: 0,
    recommended_reads_page: 1,
    honorable_mentions_page: 2
  }, prefix: true

  has_one_attached :cover_image

  validates :title, presence: true, length: { maximum: 180 }
  validates :author_name, presence: true, length: { maximum: 120 }
  validate :book_url_must_be_valid
  validate :cover_image_url_must_be_valid
  validate :cover_image_must_be_png_or_jpg_under_size_limit
  validate :at_least_one_award_selected

  before_validation :align_primary_page_toggle
  after_save :enforce_single_editor_choice, if: :saved_change_to_editor_choice?

  scope :recent_first, -> { with_attached_cover_image.order(created_at: :desc) }
  scope :editor_choices, -> { where(editor_choice: true).recent_first }
  scope :top_picks, -> { where(top_pick: true).recent_first }
  scope :recommended_reads, -> { where(recommended_read: true).recent_first }
  scope :honorable_mentions, -> { where(honorable_mention: true).recent_first }

  def cover_image_source
    return cover_image if cover_image.attached?
    return cover_image_url if cover_image_url.present?

    nil
  end

  def award_labels
    labels = []
    labels << "Editor's Choice" if editor_choice?
    labels << "Top Pick" if top_pick?
    labels << "Recommended Read" if recommended_read?
    labels << "Honorable Mention" if honorable_mention?
    labels
  end

  private

  def align_primary_page_toggle
    case primary_page
    when "top_picks_page"
      self.top_pick = true
    when "recommended_reads_page"
      self.recommended_read = true
    when "honorable_mentions_page"
      self.honorable_mention = true
    end
  end

  def enforce_single_editor_choice
    return unless editor_choice?

    self.class.where.not(id: id).where(editor_choice: true).update_all(editor_choice: false)
  end

  def at_least_one_award_selected
    return if editor_choice? || top_pick? || recommended_read? || honorable_mention?

    errors.add(:base, "Select at least one awards designation")
  end

  def book_url_must_be_valid
    return if book_url.blank?

    uri = URI.parse(book_url)
    return if uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)

    errors.add(:book_url, "must be a valid URL")
  rescue URI::InvalidURIError, TypeError
    errors.add(:book_url, "must be a valid URL")
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
