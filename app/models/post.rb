class Post < ApplicationRecord
	has_rich_text :body
	has_one_attached :featured_image
	belongs_to :post_category, optional: true
	has_many :post_taggings, dependent: :destroy
	has_many :post_tags, -> { alphabetical }, through: :post_taggings

	enum :status, { draft: 0, published: 1 }, default: :draft

	validates :title, :slug, presence: true
	validates :slug, uniqueness: true

	attr_writer :tag_list, :category_name

	before_validation :generate_slug, if: -> { title.present? && slug.blank? }
	before_validation :normalize_slug
	before_validation :assign_category_from_name
	after_save :sync_tags, if: :tag_list_assigned?

	scope :live, -> { published.where("published_at IS NULL OR published_at <= ?", Time.current) }
	scope :published_first, -> { order(published_at: :desc, created_at: :desc) }
	scope :search_query, ->(query) {
		where("posts.title LIKE :query OR posts.slug LIKE :query OR posts.excerpt LIKE :query", query: "%#{sanitize_sql_like(query.to_s.strip)}%")
	}

	def to_param
		slug
	end

	def self.filter_by_state(state)
		case state.to_s
		when "draft"
			draft
		when "scheduled"
			published.where("published_at > ?", Time.current)
		when "live"
			live
		else
			all
		end
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

	def category_name
		@category_name.to_s
	end

	def tag_list
		return @tag_list if defined?(@tag_list)

		post_tags.map(&:name).join(", ")
	end

	private

	def generate_slug
		self.slug = title.to_s.parameterize
	end

	def normalize_slug
		self.slug = slug.to_s.parameterize if slug.present?
	end

	def assign_category_from_name
		return if @category_name.nil?

		name = @category_name.to_s.squish
		self.post_category = name.present? ? PostCategory.find_or_build_by_name(name) : nil
	end

	def tag_list_assigned?
		defined?(@tag_list)
	end

	def sync_tags
		tag_names = @tag_list.to_s.split(",").map { |name| name.to_s.squish }.reject(&:blank?).uniq
		tags = tag_names.map do |name|
			PostTag.find_or_build_by_name(name).tap(&:save!)
		end

		post_tags.reload if association(:post_tags).loaded?
		self.post_tags = tags
	end
end
