class PostTag < ApplicationRecord
  has_many :post_taggings, dependent: :destroy
  has_many :posts, through: :post_taggings

  validates :name, :slug, presence: true
  validates :name, :slug, uniqueness: true

  before_validation :normalize_name
  before_validation :generate_slug

  scope :alphabetical, -> { order(:name) }

  def self.find_or_build_by_name(name)
    normalized_name = name.to_s.squish
    slug = normalized_name.parameterize

    find_or_initialize_by(slug: slug).tap do |tag|
      tag.name = normalized_name
    end
  end

  private

  def normalize_name
    self.name = name.to_s.squish
  end

  def generate_slug
    self.slug = name.to_s.parameterize if name.present?
  end
end