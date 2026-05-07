class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("SUPPORT_FROM_EMAIL", "support@authorshout.com")
  layout "mailer"
end
