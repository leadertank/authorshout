require "test_helper"

module Payments
  class FormCheckoutReadinessTest < ActiveSupport::TestCase
    FakeConfig = Struct.new(:missing_keys)

    test "free forms are ready without paypal credentials" do
      readiness = FormCheckoutReadiness.new(forms(:free_contact), config: FakeConfig.new(%w[PAYPAL_CLIENT_ID PAYPAL_CLIENT_SECRET]))

      assert_predicate readiness, :ready?
      assert_empty readiness.messages
    end

    test "paid forms report missing paypal credentials" do
      readiness = FormCheckoutReadiness.new(forms(:paid_application), config: FakeConfig.new(%w[PAYPAL_CLIENT_ID]))

      assert_not readiness.ready?
      assert_includes readiness.messages.first, "PAYPAL_CLIENT_ID"
    end

    test "subscription forms report placeholder plan ids" do
      form = forms(:subscription_intake)
      form.provider_plan_id = "REPLACE_WITH_PAYPAL_PLAN_ID"
      readiness = FormCheckoutReadiness.new(form, config: FakeConfig.new([]))

      assert_not readiness.ready?
      assert_includes readiness.messages, "Replace the placeholder PayPal plan ID before testing subscription checkout."
    end
  end
end