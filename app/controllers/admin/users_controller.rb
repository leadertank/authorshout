module Admin
  class UsersController < BaseController
    def index
      @new_member = User.new
      @admins = User.where(admin: true).order(created_at: :asc)
      @members = User.where(admin: false).order(created_at: :asc)
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
        @admins = User.where(admin: true).order(created_at: :asc)
        @members = User.where(admin: false).order(created_at: :asc)
        render :index, status: :unprocessable_entity
      end
    end

    private

    def user_params
      params.require(:user).permit(:email)
    end
  end
end
