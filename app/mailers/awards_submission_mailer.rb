class AwardsSubmissionMailer < ApplicationMailer
  def entry_received(awards_submission)
    @awards_submission = awards_submission

    mail(
      from: "support@authorshout.com",
      to: "support@authorshout.com",
      reply_to: @awards_submission.author_email,
      subject: "#{@awards_submission.form_label} entry: #{@awards_submission.book_title}"
    )
  end
end
