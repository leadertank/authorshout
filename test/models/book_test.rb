require "test_helper"

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
end
