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
end
