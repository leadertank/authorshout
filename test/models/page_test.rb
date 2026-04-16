require "test_helper"

class PageTest < ActiveSupport::TestCase
  test "live scope excludes future published pages" do
    live_page = Page.create!(title: "Live Page", slug: "live-page", layout_template: "standard", status: :published, published_at: 1.hour.ago)
    future_page = Page.create!(title: "Future Page", slug: "future-page", layout_template: "standard", status: :published, published_at: 1.day.from_now)
    draft_page = Page.create!(title: "Draft Page", slug: "draft-page", layout_template: "standard", status: :draft)

    assert_includes Page.live, live_page
    assert_not_includes Page.live, future_page
    assert_not_includes Page.live, draft_page
  end

  test "live scope includes published pages without a publish date" do
    undated_page = Page.create!(title: "Undated Page", slug: "undated-page", layout_template: "standard", status: :published, published_at: nil)

    assert_includes Page.live, undated_page
  end

  test "sanitized_builder_html removes dangerous tags and attributes" do
    page = pages(:one)
    page.builder_html = <<~HTML
      <style>.hero{color:red;}</style>
      <div onclick="alert(1)">Safe copy<script>alert(1)</script><a href="javascript:alert(2)">Bad link</a><img src="https://images.example.com/a.jpg" onerror="alert(3)"></div>
    HTML

    sanitized = page.sanitized_builder_html

    assert_includes sanitized, "<style>.hero{color:red;}</style>"
    assert_includes sanitized, "Safe copy"
    assert_not_includes sanitized, "<script>"
    assert_not_includes sanitized, "onclick"
    assert_not_includes sanitized, "onerror"
    assert_not_includes sanitized, "javascript:alert(2)"
  end
end
