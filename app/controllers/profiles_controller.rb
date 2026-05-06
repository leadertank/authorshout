class ProfilesController < ApplicationController
  before_action :authenticate_user!, only: [ :edit, :update ]
  before_action :set_profile, only: [ :show ]

  def show; end

  def edit
    @profile = current_user.profile
    @profile.books.build if @profile.books.blank?
    set_plan_state
  end

  def update
    @profile = current_user.profile

    if @profile.update(profile_params)
      redirect_to profile_path(@profile), notice: "Profile saved successfully."
    else
      @profile.books.build if @profile.books.blank?
      set_plan_state
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_profile
    requested = params[:id].to_s
    scope = Profile.includes(:user, books: :book_likes)

    @profile = scope.find_by(id: requested)
    if @profile.blank?
      slug = requested.parameterize
      @profile = scope.detect { |profile| profile.to_param == slug }
    end

    raise ActiveRecord::RecordNotFound if @profile.blank?
  end

  def profile_params
    params.require(:profile).permit(
      :bio,
      :website,
      :x_url,
      :facebook_url,
      :instagram_url,
      :threads_url,
      :bluesky_url,
      :youtube_url,
      :avatar,
      :avatar_url,
      user_attributes: [ :id, :first_name, :last_name, :email, :password, :password_confirmation ],
      books_attributes: [ :id, :title, :purchase_url, :cover_image, :cover_image_url, :_destroy ]
    )
  end

  def set_plan_state
    @book_limit = current_user.book_limit
    @book_limit_reached = @book_limit.present? && @profile.books.reject(&:marked_for_destruction?).size >= @book_limit
  end
end
