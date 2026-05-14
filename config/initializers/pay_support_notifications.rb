Pay::Webhooks.configure do |events|
  events.subscribe "stripe.charge.succeeded", lambda { |event|
    AdminNotifierMailer.payment_received(event).deliver_later
  }
end
