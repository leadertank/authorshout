require "test_helper"

class BookLikeTest < ActiveSupport::TestCase
  test "requires either user or visitor token" do
    like = BookLike.new(book: books(:one))

    assert_not like.valid?
    assert_includes like.errors[:base], "Like must belong to a user or a visitor"
  end

  test "prevents duplicate user likes per book" do
    duplicate = BookLike.new(book: books(:one), user: users(:one))

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "has already been taken"
  end

  test "increments likes_count after create for visitor likes" do
    book = books(:one)

    assert_difference -> { book.reload.likes_count }, 1 do
      BookLike.create!(book: book, visitor_token: "new-visitor-token")
    end
  end
end
