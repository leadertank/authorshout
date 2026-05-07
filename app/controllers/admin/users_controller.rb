module Admin
  class UsersController < BaseController
    def index
      @new_member = User.new
      load_users
    end

    def create
      generated_password = SecureRandom.base58(12)
      @new_member = User.new(
        email: user_params[:email],
        password: generated_password,
        password_confirmation: generated_password,
        human_verification: "1"
      )

      if @new_member.save
        redirect_to admin_users_path, notice: "Member created. Temporary password: #{generated_password}"
      else
        load_users
        render :index, status: :unprocessable_entity
      end
    end

    def destroy
      @member = User.find(params[:id])

      if @member.admin?
        redirect_to admin_users_path(q: params[:q]), alert: "Admin accounts cannot be deleted here."
        return
      end

      name = @member.display_name
      @member.destroy!
      redirect_to admin_users_path(q: params[:q]), notice: "#{name} has been deleted."
    end

    def toggle_featured_author
      @member = User.find(params[:id])

      if @member.admin?
        redirect_to admin_users_path(q: params[:q]), alert: "Featured Author status can only be changed for members."
        return
      end

      @member.update!(featured_author: !@member.featured_author?)
      status = @member.featured_author? ? "enabled" : "disabled"
      redirect_to admin_users_path(q: params[:q]), notice: "Featured Author #{status} for #{@member.display_name}."
    end

    private

    def load_users
      users = User.order(created_at: :asc)
      search = params[:q].to_s.strip.downcase

      if search.present?
        pattern = "%#{search}%"
        users = users.where(
          "LOWER(email) LIKE :pattern OR LOWER(first_name) LIKE :pattern OR LOWER(last_name) LIKE :pattern",
          pattern: pattern
        )
      end

      @query = params[:q].to_s.strip
      @admins = users.where(admin: true)
      @members = users.where(admin: false)
    end

    def user_params
      params.require(:user).permit(:email)
    end
  end
end
