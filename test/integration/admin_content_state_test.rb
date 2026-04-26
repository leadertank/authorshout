require "test_helper"

class AdminContentStateTest < ActionDispatch::IntegrationTest
  test "dashboard and content lists show draft scheduled and live states" do
    sign_in users(:two)

    Page.create!(title: "Draft Admin Page", slug: "draft-admin-page", layout_template: "standard", status: :draft)
    Page.create!(title: "Scheduled Admin Page", slug: "scheduled-admin-page", layout_template: "standard", status: :published, published_at: 1.day.from_now)
    Page.create!(title: "Live Admin Page", slug: "live-admin-page", layout_template: "standard", status: :published, published_at: 1.day.ago)

    Post.create!(title: "Draft Admin Post", slug: "draft-admin-post", status: :draft)
    Post.create!(title: "Scheduled Admin Post", slug: "scheduled-admin-post", status: :published, published_at: 1.day.from_now)
    Post.create!(title: "Live Admin Post", slug: "live-admin-post", status: :published, published_at: 1.day.ago)

    get admin_dashboard_path
    assert_response :success
    assert_match "Live Pages", response.body
    assert_match "Scheduled Pages", response.body
    assert_match "Draft Posts", response.body

    get admin_pages_path
    assert_response :success
    assert_match "Scheduled", response.body
    assert_match "Live", response.body
    assert_match "Draft", response.body

    get admin_posts_path
    assert_response :success
    assert_match "Scheduled", response.body
    assert_match "Live", response.body
    assert_match "Draft", response.body
  end
end
