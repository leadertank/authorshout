module Users
  class MasqueradesController < Devise::MasqueradesController
    protected

    def masquerade_authorized?
      return user_masquerade? if params[:action] == "back"

      current_user&.admin? && !find_masqueradable_resource&.admin?
    end

    def after_masquerade_path_for(resource)
      profile_path(resource.profile)
    end

    def after_back_masquerade_path_for(resource)
      admin_dashboard_path
    end
  end
end
