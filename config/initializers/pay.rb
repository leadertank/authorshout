Pay.setup do |config|
  config.application_name = "Authorshout"
  config.business_name = "Authorshout"
  config.support_email = "support@authorshout.com"
  config.default_product_name = "authorshout-pro"
  config.enabled_processors = [ :stripe ]
end

resolved_stripe_secret = ENV["STRIPE_SECRET_KEY"].presence ||
  Rails.application.credentials.dig(:stripe, :secret_key).presence ||
  Rails.application.credentials[:secret_key].presence

ENV["STRIPE_SECRET_KEY"] ||= resolved_stripe_secret if resolved_stripe_secret.present?
Stripe.api_key = resolved_stripe_secret

resolved_signing_secret = ENV["STRIPE_SIGNING_SECRET"].presence ||
  Rails.application.credentials.dig(:stripe, :signing_secret).presence ||
  Rails.application.credentials[:signing_secret].presence

ENV["STRIPE_SIGNING_SECRET"] ||= resolved_signing_secret if resolved_signing_secret.present?
