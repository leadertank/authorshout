require "test_helper"

class FormTest < ActiveSupport::TestCase
  test "paid forms require a positive amount" do
    form = Form.new(
      title: "Paid Lead Form",
      slug: "paid-lead-form",
      payment_mode: :one_time,
      payment_provider: "paypal",
      currency: "USD",
      amount_cents: 0,
      submit_button_text: "Pay",
      form_fields: [FormField.new(label: "Email", identifier: "email", field_type: "email", required: true, width: 12)]
    )

    assert_not form.valid?
    assert_includes form.errors[:amount_cents], "must be greater than zero for paid forms"
  end

  test "subscription forms require a plan id" do
    form = forms(:subscription_intake)
    form.provider_plan_id = nil

    assert_not form.valid?
    assert_includes form.errors[:provider_plan_id], "can't be blank"
  end

  test "requires at least one active field" do
    form = forms(:free_contact)
    form.form_fields.each { |field| field.mark_for_destruction }

    assert_not form.valid?
    assert_includes form.errors[:base], "Add at least one field to the form"
  end
end