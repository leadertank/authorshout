require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "display_name prefers full name" do
    assert_equal "Ada Lovelace", users(:one).display_name
  end

  test "display_name falls back to email prefix" do
    user = User.new(email: "fallback@example.com", password: "Password123!", password_confirmation: "Password123!")

    assert_equal "Fallback", user.display_name
  end

  test "creates a profile after create" do
    user = User.create!(
      email: "new-user@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      human_verification: "1"
    )

    assert_predicate user.profile, :present?
  end
end
