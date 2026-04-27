require "test_helper"

class AdminUserManagementTest < ActionDispatch::IntegrationTest
  test "admin can create a member from users dashboard" do
    sign_in users(:two)

    assert_difference("User.count", 1) do
      post admin_users_path, params: {
        user: {
          email: "new-member@example.com"
        }
      }
    end

    assert_redirected_to admin_users_path
    follow_redirect!

    assert_response :success
    assert_match "Member created. Temporary password:", response.body
    assert User.find_by(email: "new-member@example.com").present?
    assert User.find_by(email: "new-member@example.com").profile.present?
  end
end
