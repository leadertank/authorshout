require "csv"

module Admin
  class AwardsSubmissionsController < BaseController
    before_action :set_submission, only: [ :destroy ]

    def index
      @selected_form_key = params[:form_key].to_s.presence
      @selected_status = params[:status].to_s.presence

      @form_keys = AwardsSubmission.distinct.order(:form_key).pluck(:form_key)
      @awards_submissions = filtered_submissions

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

    def destroy
      @submission.destroy!
      redirect_to admin_awards_submissions_path(form_key: params[:form_key], status: params[:status]), notice: "Submission deleted."
    end

    def delete_non_paid
      scope = filtered_submissions.where.not(payment_status: AwardsSubmission.payment_statuses[:paid])
      deleted_count = scope.count
      scope.delete_all

      redirect_to admin_awards_submissions_path(form_key: params[:form_key], status: params[:status]), notice: "Deleted #{deleted_count} pending/failed submissions."
    end

    private

    def set_submission
      @submission = AwardsSubmission.find(params[:id])
    end

    def filtered_submissions
      submissions = AwardsSubmission.most_recent_first
      submissions = submissions.for_form(@selected_form_key) if @selected_form_key.present?

      return submissions if @selected_status.blank?

      status_key = @selected_status.to_s
      return submissions unless AwardsSubmission.payment_statuses.key?(status_key)

      submissions.where(payment_status: AwardsSubmission.payment_statuses.fetch(status_key))
    end

    def awards_submissions_csv(submissions)
      CSV.generate(headers: true) do |csv|
        csv << [
          "Form",
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
            submission.form_label,
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
