require "test_helper"

class AdminSalesTest < ActionDispatch::IntegrationTest
  test "admin can toggle a member to paid override" do
    sign_in users(:two)

    patch admin_sales_member_path(users(:one)), params: { manual_paid: "true" }

    assert_redirected_to admin_sales_path
    follow_redirect!
    assert_response :success

    users(:one).reload
    assert users(:one).manual_paid?
  end
end
