require "test_helper"
require "stringio"

class BookTest < ActiveSupport::TestCase
  test "total_likes returns cached likes count" do
    assert_equal 1, books(:one).total_likes
  end

  test "purchase_url must be a valid http url" do
    book = books(:one)
    book.purchase_url = "bad-url"

    assert_not book.valid?
    assert_includes book.errors[:purchase_url], "must be a valid URL"
  end

  test "cover_image_source falls back to cover_image_url" do
    assert_equal "https://images.example.com/ada-book.jpg", books(:one).cover_image_source
  end

  test "liked_by? returns true for an associated user like" do
    assert books(:one).liked_by?(user: users(:one))
  end

  test "liked_by? returns true for a matching visitor token" do
    assert books(:two).liked_by?(visitor_token: "visitor-123")
  end

  test "liked_by? returns false when actor has not liked the book" do
    assert_not books(:one).liked_by?(visitor_token: "different-visitor")
  end

  test "cover image must be png or jpg" do
    book = books(:one)
    book.cover_image.attach(io: StringIO.new("gif-data"), filename: "cover.gif", content_type: "image/gif")

    assert_not book.valid?
    assert_includes book.errors[:cover_image], "must be a .png or .jpg image"
  end

  test "cover image must be 2mb or smaller" do
    book = books(:one)
    book.cover_image.attach(io: StringIO.new("a" * (2.megabytes + 1)), filename: "cover.jpg", content_type: "image/jpeg")

    assert_not book.valid?
    assert_includes book.errors[:cover_image], "must be 2MB or smaller"
  end
end
