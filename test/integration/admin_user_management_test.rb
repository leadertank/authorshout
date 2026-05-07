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

  test "admin can toggle featured author for a member" do
    sign_in users(:two)

    member = users(:one)
    assert_not member.featured_author?

    patch toggle_featured_author_admin_user_path(member)

    assert_redirected_to admin_users_path
    assert member.reload.featured_author?

    patch toggle_featured_author_admin_user_path(member)

    assert_redirected_to admin_users_path
    assert_not member.reload.featured_author?
  end

  test "admin users dashboard supports search" do
    sign_in users(:two)

    get admin_users_path(q: "ada")

    assert_response :success
    assert_match "Ada Lovelace", response.body
    assert_no_match "admin@example.com", response.body
  end
end
