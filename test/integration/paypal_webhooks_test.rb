require "test_helper"

class PaypalWebhooksTest < ActionDispatch::IntegrationTest
  test "completed capture webhook marks pending submission paid" do
    submission = forms(:paid_application).form_submissions.create!(
      public_token: "webhook-order-token",
      status: :pending,
      payment_status: :payment_pending,
      payment_provider: "paypal",
      payment_reference: "ORDER-100"
    )

    with_webhook_verification(true) do
      post webhooks_paypal_path, params: {
        id: "WH-ORDER-1",
        event_type: "PAYMENT.CAPTURE.COMPLETED",
        resource: {
          id: "CAPTURE-100",
          supplementary_data: {
            related_ids: {
              order_id: "ORDER-100"
            }
          },
          payer: {
            email_address: "buyer@example.com"
          },
          status: "COMPLETED"
        }
      }.to_json, headers: { "CONTENT_TYPE" => "application/json" }
    end

    assert_response :ok
    submission.reload
    assert_equal "completed", submission.status
    assert_equal "paid", submission.payment_status
    assert_equal "CAPTURE-100", submission.payment_reference
    assert_equal "buyer@example.com", submission.provider_customer_reference
    assert_equal 1, submission.form_payment_events.count
  end

  test "subscription cancellation webhook marks payment canceled" do
    submission = forms(:subscription_intake).form_submissions.create!(
      public_token: "webhook-sub-token",
      status: :completed,
      payment_status: :paid,
      payment_provider: "paypal",
      payment_reference: "I-SUB-123",
      submitted_at: Time.current,
      paid_at: Time.current
    )

    with_webhook_verification(true) do
      post webhooks_paypal_path, params: {
        id: "WH-SUB-1",
        event_type: "BILLING.SUBSCRIPTION.CANCELLED",
        resource: {
          id: "I-SUB-123",
          status: "CANCELLED"
        }
      }.to_json, headers: { "CONTENT_TYPE" => "application/json" }
    end

    assert_response :ok
    submission.reload
    assert_equal "completed", submission.status
    assert_equal "payment_canceled", submission.payment_status
  end

  test "failed verification returns unauthorized" do
    with_webhook_verification(false) do
      post webhooks_paypal_path, params: { id: "WH-BAD", event_type: "PAYMENT.CAPTURE.COMPLETED", resource: {} }.to_json, headers: { "CONTENT_TYPE" => "application/json" }
    end

    assert_response :unauthorized
  end

  private

  def with_webhook_verification(result)
    Payments::PaypalWebhookVerifier.test_result = result
    yield
  ensure
    Payments::PaypalWebhookVerifier.test_result = nil
  end
end