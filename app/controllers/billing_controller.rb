class BillingController < ApplicationController
  before_action :authenticate_user!

  def show
    @paid_price_display = ENV.fetch("STRIPE_PAID_PRICE_DISPLAY", "$7.00")
    @paid_price_id_configured = ENV["STRIPE_PAID_PRICE_ID"].present?
  end

  def checkout
    price_id = ENV["STRIPE_PAID_PRICE_ID"].to_s
    if price_id.blank?
      redirect_to billing_path, alert: "Paid plan is not configured yet. Add STRIPE_PAID_PRICE_ID first."
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
end
