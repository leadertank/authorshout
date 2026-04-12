class Page < ApplicationRecord
	LAYOUTS = %w[standard landing showcase].freeze

	has_rich_text :body
	has_one_attached :featured_image
	has_many :page_blocks, -> { order(:position, :created_at) }, dependent: :destroy, inverse_of: :page

	accepts_nested_attributes_for :page_blocks, allow_destroy: true

	enum :status, { draft: 0, published: 1 }, default: :draft

	validates :title, :slug, :layout_template, presence: true
	validates :slug, uniqueness: true
	validates :layout_template, inclusion: { in: LAYOUTS }

	before_validation :generate_slug, if: -> { title.present? && slug.blank? }
	before_validation :normalize_slug

	scope :published_first, -> { order(published_at: :desc, created_at: :desc) }

	def to_param
		slug
	end

	private

	def generate_slug
		self.slug = title.to_s.parameterize
	end

	def normalize_slug
		self.slug = slug.to_s.parameterize if slug.present?
	end
end
