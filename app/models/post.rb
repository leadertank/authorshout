class Post < ApplicationRecord
	has_rich_text :body
	has_one_attached :featured_image

	enum :status, { draft: 0, published: 1 }, default: :draft

	validates :title, :slug, presence: true
	validates :slug, uniqueness: true

	before_validation :generate_slug, if: -> { title.present? && slug.blank? }
	before_validation :normalize_slug

	scope :live, -> { published.where("published_at IS NULL OR published_at <= ?", Time.current) }
	scope :published_first, -> { order(published_at: :desc, created_at: :desc) }

	def to_param
		slug
	end

	def scheduled?
		published? && published_at.present? && published_at.future?
	end

	def live_now?
		published? && (published_at.blank? || published_at <= Time.current)
	end

	def content_state_label
		return "Draft" if draft?
		return "Scheduled" if scheduled?

		"Live"
	end

	private

	def generate_slug
		self.slug = title.to_s.parameterize
	end

	def normalize_slug
		self.slug = slug.to_s.parameterize if slug.present?
	end
end
