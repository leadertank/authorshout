module Users
  class RegistrationsController < Devise::RegistrationsController
    before_action :capture_plan_intent, only: [ :new, :create ]

    protected

    def after_sign_up_path_for(resource)
      return checkout_billing_path if premium_plan_intended?

      super
    end

    def after_inactive_sign_up_path_for(resource)
      return checkout_billing_path if premium_plan_intended?

      super
    end

    private

    def capture_plan_intent
      plan = normalized_plan_param
      session[:post_signup_plan] = plan if plan.present?
    end

    def premium_plan_intended?
      session.delete(:post_signup_plan) == "premium"
    end

    def normalized_plan_param
      plan = params[:plan].to_s.strip.downcase
      %w[premium free].include?(plan) ? plan : nil
    end
  end
end
