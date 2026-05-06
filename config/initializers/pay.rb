Pay.setup do |config|
  config.application_name = "Authorshout"
  config.business_name = "Authorshout"
  config.support_email = "support@authorshout.com"
  config.default_product_name = "authorshout-pro"
  config.enabled_processors = [ :stripe ]
end

Stripe.api_key = ENV["STRIPE_SECRET_KEY"].presence || Rails.application.credentials.dig(:stripe, :secret_key).presence
