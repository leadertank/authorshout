admin = User.find_or_initialize_by(email: "admin@authorshout.local")
admin.password = "Password123!"
admin.password_confirmation = "Password123!"
admin.admin = true
admin.first_name = "Admin"
admin.last_name = "User"
admin.human_verification = "1"
admin.save!

contact_form = Form.find_or_initialize_by(slug: "author-strategy-call")
contact_form.assign_attributes(
	title: "Author Strategy Call",
	status: :published,
	description: "A one-time paid intake form for strategy calls and consulting sessions.",
	success_message: "Thanks. Your strategy call request has been received.",
	submit_button_text: "Continue to Payment",
	payment_mode: :one_time,
	payment_provider: "paypal",
	amount_cents: 4900,
	currency: "USD"
)
if contact_form.new_record?
	contact_form.form_fields.build(label: "Full Name", identifier: "full_name", field_type: "text", required: true, position: 1, width: 12)
	contact_form.form_fields.build(label: "Email", identifier: "email", field_type: "email", required: true, position: 2, width: 6)
	contact_form.form_fields.build(label: "Website", identifier: "website", field_type: "text", required: false, position: 3, width: 6)
	contact_form.form_fields.build(label: "What do you need help with?", identifier: "goal", field_type: "textarea", required: true, position: 4, width: 12)
end
contact_form.save!

subscription_form = Form.find_or_initialize_by(slug: "book-marketing-retainer")
subscription_form.assign_attributes(
	title: "Book Marketing Retainer",
	status: :published,
	description: "A recurring payment intake form for monthly marketing retainers.",
	success_message: "Thanks. Your subscription intake is in progress.",
	submit_button_text: "Start Subscription",
	payment_mode: :subscription,
	payment_provider: "paypal",
	amount_cents: 19900,
	currency: "USD",
	billing_interval: "month",
	provider_plan_id: "REPLACE_WITH_PAYPAL_PLAN_ID"
)
if subscription_form.new_record?
	subscription_form.form_fields.build(label: "Primary Contact", identifier: "primary_contact", field_type: "text", required: true, position: 1, width: 12)
	subscription_form.form_fields.build(label: "Business Email", identifier: "business_email", field_type: "email", required: true, position: 2, width: 6)
	subscription_form.form_fields.build(label: "Monthly Goal", identifier: "monthly_goal", field_type: "select", required: true, options_text: "Audience Growth\nLaunch Support\nOngoing Promotion", position: 3, width: 6)
	subscription_form.form_fields.build(label: "Current challenge", identifier: "current_challenge", field_type: "textarea", required: true, position: 4, width: 12)
end
subscription_form.save!

puts "Admin account ready: admin@authorshout.local / Password123!"
puts "Seeded form ready: /forms/author-strategy-call"
puts "Seeded form ready: /forms/book-marketing-retainer (replace PayPal plan ID before live subscription checkout)"
