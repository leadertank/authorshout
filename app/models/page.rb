class Page < ApplicationRecord
  LAYOUTS = %w[standard landing showcase].freeze
  BUILDER_BLOCKED_TAGS = %w[script iframe object embed form input textarea select option].freeze
  BUILDER_URL_ATTRIBUTES = %w[href src xlink:href action formaction].freeze

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
  before_validation :sanitize_builder_html

  scope :live, -> { published.where("published_at IS NULL OR published_at <= ?", Time.current) }
  scope :published_first, -> { order(published_at: :desc, created_at: :desc) }
  scope :search_query, ->(query) {
    where("pages.title LIKE :query OR pages.slug LIKE :query OR pages.summary LIKE :query", query: "%#{sanitize_sql_like(query.to_s.strip)}%")
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

  def sanitized_builder_html
    return "" if builder_html.blank?

    fragment = Loofah.fragment(builder_html)
    fragment.scrub!(builder_html_scrubber)
    fragment.to_s
  end

  private

  def generate_slug
    self.slug = title.to_s.parameterize
  end

  def normalize_slug
    self.slug = slug.to_s.parameterize if slug.present?
  end

  def sanitize_builder_html
    self.builder_html = sanitized_builder_html if builder_html.present?
  end

  def builder_html_scrubber
    @builder_html_scrubber ||= Loofah::Scrubber.new do |node|
      if BUILDER_BLOCKED_TAGS.include?(node.name)
        node.remove
        next Loofah::Scrubber::STOP
      end

      node.attribute_nodes.each do |attribute|
        name = attribute.name.downcase
        value = attribute.value.to_s.strip

        if name.start_with?("on")
          node.remove_attribute(attribute.name)
        elsif BUILDER_URL_ATTRIBUTES.include?(name) && value.match?(/\Ajavascript:/i)
          node.remove_attribute(attribute.name)
        end
      end

      nil
    end
  end
end
