require "csv"

module Admin
  class AwardsSubmissionsController < BaseController
    def index
      @awards_submissions = AwardsSubmission.most_recent_first

      respond_to do |format|
        format.html
        format.csv do
          send_data(
            awards_submissions_csv(@awards_submissions),
            filename: "book-awards-submissions-#{Date.current}.csv",
            type: "text/csv"
          )
        end
      end
    end

    private

    def awards_submissions_csv(submissions)
      CSV.generate(headers: true) do |csv|
        csv << [
          "Submitted At",
          "Payment Status",
          "Paid At",
          "First Name",
          "Last Name",
          "Email",
          "Book Title",
          "Book URL",
          "Website URL",
          "X URL",
          "Facebook URL",
          "Instagram URL",
          "Stripe Checkout Session",
          "Stripe Payment Intent",
          "Token"
        ]

        submissions.each do |submission|
          csv << [
            submission.created_at,
            submission.payment_status,
            submission.paid_at,
            submission.first_name,
            submission.last_name,
            submission.author_email,
            submission.book_title,
            submission.book_url,
            submission.website_url,
            submission.x_url,
            submission.facebook_url,
            submission.instagram_url,
            submission.stripe_checkout_session_id,
            submission.stripe_payment_intent_id,
            submission.public_token
          ]
        end
      end
    end
  end
end
