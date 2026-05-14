require "test_helper"
require "stringio"

class BookTest < ActiveSupport::TestCase
  test "purchase_url must be a valid http url" do
    book = books(:one)
    book.purchase_url = "bad-url"

    assert_not book.valid?
    assert_includes book.errors[:purchase_url], "must be a valid URL"
  end

  test "cover_image_source falls back to cover_image_url" do
    assert_equal "https://images.example.com/ada-book.jpg", books(:one).cover_image_source
  end

  test "public_featured_books keeps admin submitted and eligible member books" do
    books(:one).update_columns(featured: true)
    users(:one).update_columns(manual_paid: true)

    eligible_member_book = Book.create!(
      profile: profiles(:one),
      title: "Eligible Member Book",
      purchase_url: "https://example.com/eligible-member-book",
      cover_image_url: "https://images.example.com/eligible-member-book.jpg",
      featured: true
    )

    admin_book = Book.create!(
      title: "Admin Spotlight",
      author_name: "Author Shout",
      purchase_url: "https://example.com/admin-spotlight",
      cover_image_url: "https://images.example.com/admin-spotlight.jpg",
      featured: true,
      admin_submitted: true
    )

    ineligible_member = User.create!(
      email: "plain-member@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      first_name: "Plain",
      last_name: "Member",
      human_verification: "1"
    )

    hidden_book = Book.create!(
      profile: ineligible_member.profile,
      title: "Hidden Feature",
      purchase_url: "https://example.com/hidden-feature",
      cover_image_url: "https://images.example.com/hidden-feature.jpg",
      featured: true
    )

    featured_titles = Book.public_featured_books.map(&:title)

    assert_includes featured_titles, eligible_member_book.title
    assert_includes featured_titles, admin_book.title
    assert_includes featured_titles, books(:one).title
    assert_not_includes featured_titles, hidden_book.title
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
