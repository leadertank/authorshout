Pay::Webhooks.configure do |events|
  events.subscribe "stripe.charge.succeeded", lambda { |event|
    begin
      AdminNotifierMailer.payment_received(event).deliver_now
    rescue StandardError => error
      Rails.logger.error("Payment support notification failed for event #{event&.id}: #{error.class}: #{error.message}")
    end
  }
end
