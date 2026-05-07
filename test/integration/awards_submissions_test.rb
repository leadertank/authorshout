require "test_helper"

class AwardsSubmissionsTest < ActionDispatch::IntegrationTest
  test "renders awards submission form" do
    get new_awards_submission_path

    assert_response :success
    assert_match "8th Annual Author Shout Book Awards Submission Form", response.body
    assert_match "Submit Payment and Enter Your Book", response.body
  end

  test "shows configuration warning when stripe awards checkout is not configured" do
    assert_no_difference "AwardsSubmission.count" do
      post awards_submissions_path, params: {
        awards_submission: {
          first_name: "Ada",
          last_name: "Lovelace",
          author_email: "ada@example.com",
          book_title: "Analytical Engines for Everyone",
          book_url: "https://books.example.com/ada"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_match "Awards checkout is not configured yet", response.body
  end
end
