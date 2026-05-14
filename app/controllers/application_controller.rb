class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  skip_forgery_protection if: -> { Rails.env.development? }

  before_action :enforce_public_maintenance_mode
  before_action :configure_permitted_parameters, if: :devise_controller?
  helper_method :current_visitor_token, :maintenance_mode?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :first_name, :last_name, :human_verification ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :first_name, :last_name ])
  end

  def current_visitor_token
    cookies.permanent.signed[:visitor_token] ||= SecureRandom.uuid
  end

  def maintenance_mode?
    true
  end

  def enforce_public_maintenance_mode
    return unless maintenance_mode?
    return if controller_name == "home" && action_name == "index"

    redirect_to root_path
  end

  def after_sign_in_path_for(resource)
    return admin_dashboard_path if resource.respond_to?(:admin?) && resource.admin?

    super
  end
end
