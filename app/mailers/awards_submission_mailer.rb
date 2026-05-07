class AwardsSubmissionMailer < ApplicationMailer
  def entry_received(awards_submission)
    @awards_submission = awards_submission

    mail(
      to: ENV.fetch("SUPPORT_INBOX_EMAIL", "support@authorshout.com"),
      reply_to: @awards_submission.author_email,
      subject: "Book Awards entry: #{@awards_submission.book_title}"
    )
  end
end
