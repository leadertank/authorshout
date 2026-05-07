class AwardsSubmissionsController < ApplicationController
  def new
    @awards_submission = build_submission_from_token || AwardsSubmission.new
  end

  def create
    @awards_submission = AwardsSubmission.new(awards_submission_params)

    unless @awards_submission.valid?
      render :new, status: :unprocessable_entity
      return
    end

    unless awards_checkout_configured?
      flash.now[:alert] = "Awards checkout is not configured yet. Add STRIPE_AWARDS_PRICE_ID and STRIPE_SECRET_KEY."
      render :new, status: :unprocessable_entity
      return
    end

    @awards_submission.save!
    ensure_stripe_api_key!

    checkout_session = Stripe::Checkout::Session.create(
      mode: "payment",
      line_items: [
        {
          price: awards_price_id,
          quantity: 1
        }
      ],
      customer_email: @awards_submission.author_email,
      success_url: awards_submission_success_url(
        token: @awards_submission.public_token,
        session_id: "{CHECKOUT_SESSION_ID}"
      ),
      cancel_url: new_awards_submission_url(token: @awards_submission.public_token),
      metadata: {
        awards_submission_token: @awards_submission.public_token,
        form_name: "8th Annual Author Shout Book Awards"
      }
    )

    @awards_submission.update!(stripe_checkout_session_id: checkout_session.id)

    redirect_to checkout_session.url, allow_other_host: true, status: :see_other
  rescue StandardError => error
    Rails.logger.error("Awards submission checkout failed: #{error.class}: #{error.message}")
    flash.now[:alert] = "We could not start checkout right now. Please try again."
    render :new, status: :unprocessable_entity
  end

  def success
    @awards_submission = AwardsSubmission.find_by!(public_token: params[:token].to_s)

    if params[:session_id].blank?
      redirect_to new_awards_submission_path(token: @awards_submission.public_token), alert: "Checkout was not completed yet."
      return
    end

    ensure_stripe_api_key!
    checkout_session = Stripe::Checkout::Session.retrieve(params[:session_id])

    if checkout_session.payment_status == "paid"
      mark_submission_paid!(@awards_submission, checkout_session)
      send_support_email_once!(@awards_submission)
      return
    end

    @awards_submission.update!(payment_status: :failed)
    redirect_to new_awards_submission_path(token: @awards_submission.public_token), alert: "Payment was not completed. Please try again."
  rescue ActiveRecord::RecordNotFound
    redirect_to new_awards_submission_path, alert: "Submission not found. Please complete the form again."
  rescue StandardError => error
    Rails.logger.error("Awards submission success handling failed: #{error.class}: #{error.message}")
    redirect_to new_awards_submission_path, alert: "We could not verify payment right now. Please contact support if you were charged."
  end

  private

  def awards_submission_params
    params.require(:awards_submission).permit(
      :first_name,
      :last_name,
      :author_email,
      :book_title,
      :book_url,
      :website_url,
      :x_url,
      :facebook_url,
      :instagram_url
    )
  end

  def build_submission_from_token
    return if params[:token].blank?

    saved = AwardsSubmission.find_by(public_token: params[:token].to_s)
    return if saved.blank?

    AwardsSubmission.new(
      first_name: saved.first_name,
      last_name: saved.last_name,
      author_email: saved.author_email,
      book_title: saved.book_title,
      book_url: saved.book_url,
      website_url: saved.website_url,
      x_url: saved.x_url,
      facebook_url: saved.facebook_url,
      instagram_url: saved.instagram_url
    )
  end

  def mark_submission_paid!(submission, checkout_session)
    updates = {
      stripe_checkout_session_id: checkout_session.id,
      stripe_payment_intent_id: checkout_session.payment_intent,
      payment_status: :paid
    }

    updates[:paid_at] = Time.current if submission.paid_at.blank?
    submission.update!(updates)
  end

  def send_support_email_once!(submission)
    return if submission.support_emailed_at.present?

    AwardsSubmissionMailer.entry_received(submission).deliver_now
    submission.update!(support_emailed_at: Time.current)
  end

  def awards_checkout_configured?
    awards_price_id.present? && stripe_secret_key.present?
  end

  def awards_price_id
    ENV["STRIPE_AWARDS_PRICE_ID"].presence ||
      Rails.application.credentials.dig(:stripe, :awards_price_id).presence
  end

  def stripe_secret_key
    ENV["STRIPE_SECRET_KEY"].presence ||
      Rails.application.credentials.dig(:stripe, :secret_key).presence ||
      Rails.application.credentials[:secret_key].presence
  end

  def ensure_stripe_api_key!
    return if stripe_secret_key.blank?

    ENV["STRIPE_SECRET_KEY"] ||= stripe_secret_key
    Stripe.api_key = stripe_secret_key
  end
end
