require "test_helper"

class FormSubmissionsTest < ActionDispatch::IntegrationTest
  FakeCheckout = Struct.new(:approval_url, :external_id, :payload, keyword_init: true)

  test "free form submission completes immediately" do
    post submit_form_path(forms(:free_contact).slug), params: {
      form_response: {
        full_name: "Reader Person",
        email: "reader@example.com",
        topic: "Interview"
      }
    }

    submission = FormSubmission.order(:created_at).last

    assert_redirected_to form_submission_complete_path(forms(:free_contact).slug, submission.public_token)
    follow_redirect!
    assert_response :success
    assert_match "Thanks for reaching out", response.body
    assert_equal "completed", submission.status
    assert_equal "not_required", submission.payment_status
  end

  test "paid form submission redirects to gateway approval url" do
    fake_gateway = Object.new
    fake_gateway.define_singleton_method(:start_checkout) do |**_args|
      FakeCheckout.new(approval_url: "https://paypal.example.test/approve", external_id: "ORDER-999", payload: { id: "ORDER-999" })
    end

    Payments::Gateway.test_gateway = fake_gateway

    begin
      post submit_form_path(forms(:paid_application).slug), params: {
        form_response: {
          applicant_name: "Buyer Person",
          applicant_email: "buyer@example.com",
          accept_terms: "1"
        }
      }
    ensure
      Payments::Gateway.test_gateway = nil
    end

    submission = FormSubmission.order(:created_at).last

    assert_redirected_to "https://paypal.example.test/approve"
    assert_equal "pending", submission.status
    assert_equal "payment_pending", submission.payment_status
    assert_equal "ORDER-999", submission.payment_reference
  end
end