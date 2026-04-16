require "test_helper"

class AdminPreviewsTest < ActionDispatch::IntegrationTest
  test "admin can preview a draft page" do
    sign_in users(:two)

    page = Page.create!(
      title: "Draft Preview Page",
      slug: "draft-preview-page",
      layout_template: "standard",
      status: :draft,
      summary: "Draft summary"
    )

    get preview_admin_page_path(page)

    assert_response :success
    assert_match "Draft Preview Page", response.body
    assert_match "Draft summary", response.body
  end

  test "admin can preview a future post" do
    sign_in users(:two)

    post = Post.create!(
      title: "Future Preview Post",
      slug: "future-preview-post",
      status: :published,
      published_at: 2.days.from_now,
      excerpt: "Coming soon"
    )

    get preview_admin_post_path(post)

    assert_response :success
    assert_match "Future Preview Post", response.body
    assert_match "Coming soon", response.body
  end

  test "non admin cannot access preview routes" do
    sign_in users(:one)

    get preview_admin_page_path(pages(:one))

    assert_redirected_to root_path
  end
end