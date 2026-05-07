module Admin
  class SalesController < BaseController
    before_action :set_member, only: [ :update_member ]
    before_action :ensure_stripe_api_key!, only: [ :index, :create_product, :update_product ]

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
      raise "Stripe API key is missing" if stripe_private_key.blank?
    end

    def load_stripe_catalog
      return @stripe_products = [] if stripe_private_key.blank?

      relevant_price_ids = [ paid_price_id, awards_price_id, social_blitz_price_id ].compact.uniq
      return @stripe_products = [] if relevant_price_ids.empty?

      product_labels = Hash.new { |hash, key| hash[key] = [] }

      product_ids = relevant_price_ids.filter_map do |price_id|
        price = Stripe::Price.retrieve(price_id)
        product_id = price.product
        product_labels[product_id] << label_for_price_id(price_id)
        product_id
      rescue StandardError
        nil
      end.uniq

      @stripe_products = product_ids.map do |product_id|
        product = Stripe::Product.retrieve(product_id)
        prices = Stripe::Price.list(product: product.id, active: true, limit: 5).data
        {
          product: product,
          prices: prices,
          labels: product_labels[product.id].uniq
        }
      end
    rescue StandardError => e
      @stripe_products = []
      flash.now[:alert] = "Could not load Stripe catalog: #{e.message}"
    end

    def ensure_stripe_api_key!
      return if stripe_private_key.blank?

      ENV["STRIPE_SECRET_KEY"] ||= stripe_private_key
      Stripe.api_key = stripe_private_key
    end

    def stripe_private_key
      ENV["STRIPE_PRIVATE_KEY"].presence ||
        ENV["STRIPE_SECRET_KEY"].presence ||
        Rails.application.credentials.dig(:stripe, :private_key).presence ||
        Rails.application.credentials.dig(:stripe, :secret_key).presence ||
        Rails.application.credentials[:secret_key].presence
    end

    def paid_price_id
      ENV["STRIPE_PAID_PRICE_ID"].presence ||
        Rails.application.credentials.dig(:stripe, :paid_price_id).presence ||
        Rails.application.credentials[:paid_price_id].presence
    end

    def awards_price_id
      ENV["STRIPE_AWARDS_PRICE_ID"].presence ||
        Rails.application.credentials.dig(:stripe, :awards_price_id).presence
    end

    def social_blitz_price_id
      ENV["STRIPE_SOCIAL_BLITZ_PRICE_ID"].presence ||
        Rails.application.credentials.dig(:stripe, :social_blitz_price_id).presence
    end

    def label_for_price_id(price_id)
      return "Membership" if price_id == paid_price_id
      return "Awards" if price_id == awards_price_id
      return "Social Blitz" if price_id == social_blitz_price_id

      "Relevant"
    end
  end
end
