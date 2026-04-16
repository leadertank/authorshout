require "test_helper"

class ProfileTest < ActiveSupport::TestCase
  test "social_links returns only present values" do
    links = profiles(:one).social_links

    assert_equal "https://x.com/ada", links["X"]
    assert_equal "https://youtube.com/@ada", links["YouTube"]
    assert_nil links["Website"]
  end

  test "avatar_url must be a valid http url" do
    profile = profiles(:one)
    profile.avatar_url = "not-a-url"

    assert_not profile.valid?
    assert_includes profile.errors[:avatar_url], "must be a valid URL"
  end
end
