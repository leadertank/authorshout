require "test_helper"

class AdminImpersonationTest < ActionDispatch::IntegrationTest
  test "admin can impersonate a member and switch back" do
    admin = users(:two)
    member = users(:one)

    sign_in admin

    get admin_users_path
    assert_response :success

    get user_masquerade_index_path(
      masquerade: member.masquerade_key,
      masqueraded_resource_class: member.class.name
    )
    assert_redirected_to profile_path(member.profile)

    follow_redirect!
    assert_response :success
    assert_match "Impersonating #{member.email}", response.body
    assert_match "Return to Admin", response.body

    get back_user_masquerade_index_path
    assert_redirected_to admin_dashboard_path

    follow_redirect!
    assert_response :success
    assert_match "Admin Dashboard", response.body
  end
end
