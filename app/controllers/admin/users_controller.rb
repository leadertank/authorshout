module Admin
  class UsersController < BaseController
    def index
      @admins = User.where(admin: true).order(created_at: :asc)
      @members = User.where(admin: false).order(created_at: :asc)
    end
  end
end
