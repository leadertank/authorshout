require "test_helper"

class AdminAwardsSubmissionsTest < ActionDispatch::IntegrationTest
  test "admin can view awards submissions" do
    sign_in users(:two)

    get admin_awards_submissions_path

    assert_response :success
    assert_match "Book Awards Submissions", response.body
    assert_match "Analytical Engines for Everyone", response.body
  end

  test "admin can export awards submissions csv" do
    sign_in users(:two)

    get admin_awards_submissions_path(format: :csv)

    assert_response :success
    assert_includes response.media_type, "text/csv"
    assert_includes response.body, "Book Title"
    assert_includes response.body, "Analytical Engines for Everyone"
  end
end
