module Admin
  class SalesController < BaseController
    before_action :set_member, only: [ :update_member ]

    def index
      @members = User.where(admin: false).includes(:profile, :pay_customers).order(created_at: :desc)
      @total_signups = @members.count
      @paid_members = @members.select(&:paid_member?).count
      @free_members = @total_signups - @paid_members
      @total_revenue_cents = Pay::Charge.where("amount > 0").sum(:amount)
      @paid_price_id_configured = paid_price_id.present?

      load_stripe_catalog
    end

    def update_member
      @member.update!(manual_paid: ActiveModel::Type::Boolean.new.cast(params[:manual_paid]))
      redirect_to admin_sales_path, notice: "Membership override updated for #{@member.email}."
    end

    def create_product
      require_stripe_configuration!

      product = Stripe::Product.create(
        name: product_params[:name],
        description: product_params[:description].presence,
        active: true
      )

      Stripe::Price.create(
        product: product.id,
        unit_amount: dollars_to_cents(product_params[:price]),
        currency: "usd",
        recurring: { interval: product_params[:interval] }
      )

      redirect_to admin_sales_path, notice: "Product created in Stripe."
    rescue StandardError => e
      redirect_to admin_sales_path, alert: "Unable to create product: #{e.message}"
    end

    def update_product
      require_stripe_configuration!

      product_id = params[:id]
      Stripe::Product.update(product_id, {
        name: product_params[:name],
        description: product_params[:description].presence,
        active: ActiveModel::Type::Boolean.new.cast(product_params[:active])
      })

      if product_params[:price].present?
        latest_active_price = Stripe::Price.list(product: product_id, active: true, limit: 1).data.first

        Stripe::Price.create(
          product: product_id,
          unit_amount: dollars_to_cents(product_params[:price]),
          currency: "usd",
          recurring: { interval: product_params[:interval] }
        )

        Stripe::Price.update(latest_active_price.id, { active: false }) if latest_active_price.present?
      end

      redirect_to admin_sales_path, notice: "Product updated in Stripe."
    rescue StandardError => e
      redirect_to admin_sales_path, alert: "Unable to update product: #{e.message}"
    end

    private

    def set_member
      @member = User.find(params[:id])
    end

    def product_params
      params.require(:product).permit(:name, :description, :price, :interval, :active)
    end

    def dollars_to_cents(amount)
      (BigDecimal(amount.to_s) * 100).to_i
    end

    def require_stripe_configuration!
      raise "Stripe private key is missing" if stripe_private_key.blank?
    end

    def load_stripe_catalog
      return @stripe_products = [] if stripe_private_key.blank?

      products = Stripe::Product.list(limit: 100).data
      @stripe_products = products.map do |product|
        prices = Stripe::Price.list(product: product.id, active: true, limit: 5).data
        {
          product: product,
          prices: prices
        }
      end
    rescue StandardError
      @stripe_products = []
      flash.now[:alert] = "Could not load Stripe catalog. Check Stripe credentials."
    end

    def stripe_private_key
      ENV["STRIPE_PRIVATE_KEY"].presence || Rails.application.credentials.dig(:stripe, :private_key).presence
    end

    def paid_price_id
      ENV["STRIPE_PAID_PRICE_ID"].presence || Rails.application.credentials.dig(:stripe, :paid_price_id).presence
    end
  end
end
