class MembershipController < ApplicationController
  def show
    @paid_price_display = paid_price_display
  end

  private

  def paid_price_display
    ENV["STRIPE_PAID_PRICE_DISPLAY"].presence ||
      Rails.application.credentials.dig(:stripe, :paid_price_display).presence ||
      Rails.application.credentials[:paid_price_display].presence ||
      "$7.00"
  end
end
