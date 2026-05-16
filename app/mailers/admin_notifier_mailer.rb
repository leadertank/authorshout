class AdminNotifierMailer < ApplicationMailer
  def new_member_signup(user)
    @user = user

    mail(
      from: "Author Shout <support@authorshout.com>",
      to: admin_alert_to,
      bcc: admin_alert_bcc,
      reply_to: @user.email,
      subject: "New member signup: #{@user.email}"
    )
  end

  def payment_received(event)
    @event = event
    @event_type = extract_event_type(event)
    @event_id = extract_event_id(event)
    @customer_email = extract_customer_email(event)
    @amount_cents = extract_amount_cents(event)
    @currency = extract_currency(event)
    @subscription_id = extract_subscription_id(event)

    mail(
      from: "Author Shout <support@authorshout.com>",
      to: admin_alert_to,
      bcc: admin_alert_bcc,
      reply_to: @customer_email.presence || "support@authorshout.com",
      subject: "Payment received#{" from #{@customer_email}" if @customer_email.present?}"
    )
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

  def admin_alert_to
    ENV.fetch("ADMIN_ALERT_TO", "support@authorshout.com")
  end

  def admin_alert_bcc
    monitor = ENV.fetch("ADMIN_ALERT_MONITOR", "sales@authorshout.com").to_s.strip
    return if monitor.empty?
    return if monitor.casecmp?(admin_alert_to)

    monitor
  end
end
