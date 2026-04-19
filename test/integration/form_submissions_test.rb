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
      with_paypal_env("PAYPAL_CLIENT_ID" => "sandbox-id", "PAYPAL_CLIENT_SECRET" => "sandbox-secret") do
        post submit_form_path(forms(:paid_application).slug), params: {
          form_response: {
            applicant_name: "Buyer Person",
            applicant_email: "buyer@example.com",
            accept_terms: "1"
          }
        }
      end
    ensure
      Payments::Gateway.test_gateway = nil
    end

    submission = FormSubmission.order(:created_at).last

    assert_redirected_to "https://paypal.example.test/approve"
    assert_equal "pending", submission.status
    assert_equal "payment_pending", submission.payment_status
    assert_equal "ORDER-999", submission.payment_reference
  end

  test "paid form shows payment unavailable when paypal is not configured" do
    with_paypal_env("PAYPAL_CLIENT_ID" => nil, "PAYPAL_CLIENT_SECRET" => nil) do
      get form_path(forms(:paid_application).slug)

      assert_response :success
      assert_match "Payment temporarily unavailable", response.body
      assert_match "Missing PayPal credentials", response.body
    end
  end

  private

  def with_paypal_env(overrides)
    original = overrides.each_with_object({}) { |(key, _value), memo| memo[key] = ENV[key] }
    overrides.each do |key, value|
      value.nil? ? ENV.delete(key) : ENV[key] = value
    end
    yield
  ensure
    original.each do |key, value|
      value.nil? ? ENV.delete(key) : ENV[key] = value
    end
  end
end