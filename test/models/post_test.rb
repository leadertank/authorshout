require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "live scope excludes future published posts" do
    live_post = Post.create!(title: "Live Post", slug: "live-post", status: :published, published_at: 2.hours.ago)
    future_post = Post.create!(title: "Future Post", slug: "future-post", status: :published, published_at: 2.days.from_now)
    draft_post = Post.create!(title: "Draft Post", slug: "draft-post", status: :draft)

    assert_includes Post.live, live_post
    assert_not_includes Post.live, future_post
    assert_not_includes Post.live, draft_post
  end

  test "live scope includes published posts without a publish date" do
    undated_post = Post.create!(title: "Undated Post", slug: "undated-post", status: :published, published_at: nil)

    assert_includes Post.live, undated_post
  end

  test "content state label returns draft scheduled and live" do
    draft_post = Post.new(title: "Draft", slug: "draft-post-label", status: :draft)
    scheduled_post = Post.new(title: "Scheduled", slug: "scheduled-post-label", status: :published, published_at: 3.hours.from_now)
    live_post = Post.new(title: "Live", slug: "live-post-label", status: :published, published_at: 3.hours.ago)

    assert_equal "Draft", draft_post.content_state_label
    assert_equal "Scheduled", scheduled_post.content_state_label
    assert_equal "Live", live_post.content_state_label
    assert_predicate scheduled_post, :scheduled?
    assert_predicate live_post, :live_now?
  end

  test "category name creates or reuses a category" do
    post = Post.create!(title: "Categorized", slug: "categorized", status: :draft, category_name: "Editorial")

    assert_equal "Editorial", post.post_category.name
    assert_equal "editorial", post.post_category.slug
  end

  test "tag list syncs comma separated tags" do
    post = posts(:one)

    post.update!(tag_list: "Launch, Community, Essays")

    assert_equal [ "Community", "Essays", "Launch" ], post.post_tags.order(:name).pluck(:name)
  end
end
