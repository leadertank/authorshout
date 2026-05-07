class SupportMailer < ApplicationMailer
  def contact_request(support_message)
    @support_message = support_message

    mail(
      to: ENV.fetch("SUPPORT_INBOX_EMAIL", "support@authorshout.com"),
      reply_to: @support_message.email,
      subject: "Support request from #{@support_message.name}"
    )
  end
end
