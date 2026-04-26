require "test_helper"

class AdminContentFiltersTest < ActionDispatch::IntegrationTest
  test "admin can filter pages by state and layout" do
    sign_in users(:two)

    Page.create!(title: "Draft Showcase", slug: "draft-showcase", layout_template: "showcase", status: :draft)
    Page.create!(title: "Live Standard", slug: "live-standard", layout_template: "standard", status: :published, published_at: 1.day.ago)

    get admin_pages_path, params: { state: "draft", layout: "showcase", query: "Draft" }

    assert_response :success
    assert_match "Draft Showcase", response.body
    assert_no_match "Live Standard", response.body
  end

  test "admin can filter posts by state category tag and search" do
    sign_in users(:two)

    post = Post.create!(
      title: "Product Launch Notes",
      slug: "product-launch-notes",
      status: :published,
      published_at: 1.day.ago,
      category_name: "Product",
      tag_list: "Launch, Roadmap",
      excerpt: "Release planning"
    )

    get admin_posts_path, params: {
      state: "live",
      post_category_id: post.post_category_id,
      post_tag_id: post.post_tags.find_by!(slug: "launch").id,
      query: "Launch"
    }

    assert_response :success
    assert_match "Product Launch Notes", response.body
    assert_no_match "Interview Post", response.body
  end
end
