require "test_helper"

class HomeBooksNavigationTest < ActionDispatch::IntegrationTest
  test "home paginates featured and latest books separately" do
    9.times do |index|
      Book.create!(
        title: "Featured Admin Book #{index}",
        author_name: "Author #{index}",
        purchase_url: "https://example.com/featured-admin-book-#{index}",
        cover_image_url: "https://images.example.com/featured-admin-book-#{index}.jpg",
        featured: true,
        admin_submitted: true,
        created_at: index.hours.ago
      )
    end

    9.times do |index|
      Book.create!(
        title: "Latest Admin Book #{index}",
        author_name: "Latest #{index}",
        purchase_url: "https://example.com/latest-admin-book-#{index}",
        cover_image_url: "https://images.example.com/latest-admin-book-#{index}.jpg",
        featured: false,
        admin_submitted: true,
        created_at: (index + 20).hours.ago
      )
    end

    get root_path

    assert_response :success
    assert_match "View All Featured", response.body
    assert_match "Featured Admin Book 0", response.body
    assert_no_match "Featured Admin Book 8", response.body
    assert_match "Latest Admin Book 0", response.body
    assert_no_match "Latest Admin Book 8", response.body
    assert_match "featured_page=2", response.body
    assert_match "latest_page=2", response.body

    get root_path(featured_page: 2, latest_page: 2)

    assert_response :success
    assert_match "Featured Admin Book 8", response.body
    assert_match "Latest Admin Book 8", response.body
  end

  test "featured books page lists every featured book" do
    users(:one).update_columns(manual_paid: true)

    get featured_books_path

    assert_response :success
    assert_match "Featured Books", response.body
    assert_match books(:one).title, response.body
  end

  test "products page shows updated call to action copy" do
    get products_path

    assert_response :success
    assert_match "Click to view details", response.body
    assert_match "Enter your book in the Author Shout awards program.", response.body
  end

  test "home shows awards banner" do
    get root_path

    assert_response :success
    assert_match "8th%20Annual%20Author%20Shout%20Awards%20Banner.png", response.body
  end
end
