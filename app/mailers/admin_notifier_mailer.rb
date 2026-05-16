class AdminNotifierMailer < ApplicationMailer
  # Send one copy per admin address for maximum inbox deliverability.
  # Call AdminNotifierMailer.notify_new_member_signup(user) to dispatch to all.
  def new_member_signup(user, recipient:)
    @user = user

    mail(
      from: "Author Shout <support@authorshout.com>",
      to: recipient,
      reply_to: support_reply_to,
      subject: "New member signup: #{@user.email}"
    )
  end

  def self.notify_new_member_signup(user)
    admin_alert_addresses.each do |address|
      new_member_signup(user, recipient: address).deliver_later
    end
  end

  def payment_received(event, recipient:)
    @event = event
    @event_type = extract_event_type(event)
    @event_id = extract_event_id(event)
    @customer_email = extract_customer_email(event)
    @amount_cents = extract_amount_cents(event)
    @currency = extract_currency(event)
    @subscription_id = extract_subscription_id(event)

    mail(
      from: "Author Shout <support@authorshout.com>",
      to: recipient,
      reply_to: support_reply_to,
      subject: "Payment received#{" from #{@customer_email}" if @customer_email.present?}"
    )
  end

  def self.notify_payment_received(event)
    admin_alert_addresses.each do |address|
      payment_received(event, recipient: address).deliver_later
    end
  end

  private

  def event_object(event)
    data = event.respond_to?(:data) ? event.data : nil
    return data.object if data.respond_to?(:object)

    return nil unless data.respond_to?(:to_h)

    data_hash = data.to_h
    data_hash["object"] || data_hash[:object]
  end

  def extract_event_type(event)
    event.respond_to?(:type) ? event.type : "unknown"
  end

  def extract_event_id(event)
    event.respond_to?(:id) ? event.id : "unknown"
  end

  def extract_customer_email(event)
    object = event_object(event)
    return if object.nil?

    return object.customer_email if object.respond_to?(:customer_email)

    if object.respond_to?(:billing_details)
      details = object.billing_details
      return details.email if details.respond_to?(:email)
    end

    if object.respond_to?(:to_h)
      hash = object.to_h
      return hash.dig("billing_details", "email") || hash.dig(:billing_details, :email)
    end

    nil
  end

  def extract_amount_cents(event)
    object = event_object(event)
    return unless object.respond_to?(:amount)

    object.amount
  end

  def extract_currency(event)
    object = event_object(event)
    return unless object.respond_to?(:currency)

    object.currency.to_s.upcase
  end

  def extract_subscription_id(event)
    object = event_object(event)
    return unless object.respond_to?(:subscription)

    object.subscription
  end

  def self.admin_alert_addresses
    primary   = ENV.fetch("ADMIN_ALERT_TO", "authorshoutbooks@gmail.com")
    extras    = ENV.fetch("ADMIN_ALERT_EXTRA_TO",
                          "sales@authorshout.com,support@authorshout.com").split(",")

    [primary, *extras]
      .map    { |a| a.to_s.strip }
      .reject(&:empty?)
      .uniq   { |a| a.downcase }
  end

  def support_reply_to
    "support@authorshout.com"
  end
end
