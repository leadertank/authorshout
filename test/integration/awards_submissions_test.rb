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

  test "success uses saved checkout session when placeholder session id is returned" do
    submission = awards_submissions(:one)
    submission.update!(payment_status: :pending, support_emailed_at: nil)

    checkout_stub = Struct.new(:id, :payment_status, :payment_intent).new("cs_test_123", "paid", "pi_test_paid")

    stripe_checkout_session_singleton = Stripe::Checkout::Session.singleton_class
    stripe_checkout_session_singleton.alias_method :__original_retrieve_for_test, :retrieve
    stripe_checkout_session_singleton.define_method(:retrieve) { |_session_id| checkout_stub }

    begin
      assert_emails 1 do
        get awards_submission_success_path(token: submission.public_token), params: { session_id: "{CHECKOUT_SESSION_ID}" }
      end
    ensure
      stripe_checkout_session_singleton.alias_method :retrieve, :__original_retrieve_for_test
      stripe_checkout_session_singleton.remove_method :__original_retrieve_for_test
    end

    assert_response :success
    submission.reload
    assert submission.paid?
    assert_equal "pi_test_paid", submission.stripe_payment_intent_id
    assert submission.support_emailed_at.present?
  end
end
