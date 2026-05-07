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

  test "admin can delete pending and failed submissions" do
    sign_in users(:two)

    pending_submission = AwardsSubmission.create!(
      first_name: "Test",
      last_name: "Pending",
      author_email: "pending@example.com",
      book_title: "Pending Book",
      book_url: "https://example.com/pending",
      payment_status: :pending
    )

    failed_submission = AwardsSubmission.create!(
      first_name: "Test",
      last_name: "Failed",
      author_email: "failed@example.com",
      book_title: "Failed Book",
      book_url: "https://example.com/failed",
      payment_status: :failed
    )

    assert_difference("AwardsSubmission.count", -2) do
      delete delete_non_paid_admin_awards_submissions_path
    end

    assert_redirected_to admin_awards_submissions_path
    assert_not AwardsSubmission.exists?(pending_submission.id)
    assert_not AwardsSubmission.exists?(failed_submission.id)
    assert AwardsSubmission.exists?(awards_submissions(:one).id)
  end
end
