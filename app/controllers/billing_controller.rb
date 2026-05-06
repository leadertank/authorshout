class BillingController < ApplicationController
  before_action :authenticate_user!

  def show
    @paid_price_display = paid_price_display
    @paid_price_id_configured = paid_price_id.present?
  end

  def checkout
    price_id = paid_price_id.to_s
    if price_id.blank?
      if user_masquerade? && current_user.present? && !current_user.admin?
        current_user.update!(manual_paid: true)
        redirect_to billing_path, notice: "Stripe checkout is not configured yet. Applied PAID access for impersonation testing."
        return
      end

      redirect_to billing_path, alert: "Paid plan is not configured yet. Add STRIPE_PAID_PRICE_ID (or credentials stripe.paid_price_id)."
      return
    end

    current_user.set_payment_processor(:stripe)
    checkout_session = current_user.payment_processor.checkout(
      mode: "subscription",
      line_items: price_id,
      success_url: billing_url,
      cancel_url: billing_url,
      client_reference_id: Pay::Stripe.to_client_reference_id(current_user)
    )

    redirect_to checkout_session.url, allow_other_host: true
  rescue StandardError => e
    redirect_to billing_path, alert: "Unable to start checkout: #{e.message}"
  end

  def portal
    current_user.set_payment_processor(:stripe)
    portal_session = current_user.payment_processor.billing_portal(return_url: billing_url)
    redirect_to portal_session.url, allow_other_host: true
  rescue StandardError => e
    redirect_to billing_path, alert: "Unable to open billing portal: #{e.message}"
  end

  private

  def paid_price_id
    ENV["STRIPE_PAID_PRICE_ID"].presence || Rails.application.credentials.dig(:stripe, :paid_price_id).presence
  end

  def paid_price_display
    ENV["STRIPE_PAID_PRICE_DISPLAY"].presence || Rails.application.credentials.dig(:stripe, :paid_price_display).presence || "$7.00"
  end
end
