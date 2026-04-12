class BookLike < ApplicationRecord
  belongs_to :book
  belongs_to :user, optional: true

  validates :visitor_token, presence: true, unless: :user_id?
  validates :user_id, uniqueness: { scope: :book_id }, if: :user_id?
  validates :visitor_token, uniqueness: { scope: :book_id }, unless: :user_id?
  validate :actor_presence

  after_create_commit :increment_book_likes_count

  private

  def increment_book_likes_count
    book.increment!(:likes_count)
  end

  def actor_presence
    return if user_id.present? || visitor_token.present?

    errors.add(:base, "Like must belong to a user or a visitor")
  end
end
