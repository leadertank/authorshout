class ProfilesController < ApplicationController
  before_action :authenticate_user!, only: [ :edit, :update ]
  before_action :set_profile, only: [ :show ]

  def show; end

  def edit
    @profile = current_user.profile
    # Ensure featured book exists
    if @profile.books.where(featured: true).blank?
      @profile.books.build(featured: true)
    end
  end

  def update
    @profile = current_user.profile

    if @profile.update(profile_params)
      redirect_to profile_path(@profile), notice: "Profile saved successfully."
    else
      # Ensure featured book exists for re-render
      if @profile.books.where(featured: true).blank?
        @profile.books.build(featured: true)
      end
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_profile
    @profile = Profile.includes(:user, books: :book_likes).find(params[:id])
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
      user_attributes: [ :id, :first_name, :last_name ],
      books_attributes: [ :id, :title, :purchase_url, :cover_image, :cover_image_url, :featured, :_destroy ]
    )
  end
end
