Pay.setup do |config|
  config.application_name = "Authorshout"
  config.business_name = "Authorshout"
  config.support_email = "support@authorshout.com"
  config.default_product_name = "authorshout-pro"
  config.enabled_processors = [ :stripe ]
end
