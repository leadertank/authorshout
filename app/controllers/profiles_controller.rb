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
    attachment_cleanup_plan = build_attachment_cleanup_plan

    if @profile.update(profile_params)
      purge_replaced_or_removed_uploads(attachment_cleanup_plan)
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
    scope = Profile.includes(:user, books: :book_likes).merge(Book.order(featured: :desc, created_at: :asc))

    @profile = scope.find_by(id: requested)
    if @profile.blank?
      slug = requested.parameterize
      @profile = scope.detect { |profile| profile.to_param == slug }
    end

    raise ActiveRecord::RecordNotFound if @profile.blank?
  end

  def profile_params
    permitted = params.require(:profile).permit(
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
      books_attributes: [ :id, :title, :purchase_url, :cover_image, :cover_image_url, :featured, :_destroy ]
    )

    user_attributes = permitted[:user_attributes]
    if user_attributes.present? && user_attributes[:password].blank? && user_attributes[:password_confirmation].blank?
      user_attributes.delete(:password)
      user_attributes.delete(:password_confirmation)
    end

    unless current_user.paid_member? || current_user.featured_author?
      books_attributes = permitted[:books_attributes]
      books_attributes&.each_value { |book_attrs| book_attrs[:featured] = "0" }
    end

    permitted
  end

  def set_plan_state
    @book_limit = current_user.book_limit
    @book_limit_reached = @book_limit.present? && @profile.books.reject(&:marked_for_destruction?).size >= @book_limit
  end

  def build_attachment_cleanup_plan
    raw_profile_params = params.fetch(:profile, ActionController::Parameters.new)
    avatar_upload_present = raw_profile_params[:avatar].present?

    avatar_action = :replace if avatar_upload_present

    books_plan = []
    raw_books_attributes = raw_profile_params[:books_attributes] || {}

    raw_books_attributes.each_value do |book_attrs|
      next if truthy_param?(book_attrs[:_destroy] || book_attrs["_destroy"])

      book_id = book_attrs[:id] || book_attrs["id"]
      next if book_id.blank?

      book = @profile.books.find { |existing_book| existing_book.id.to_s == book_id.to_s }
      next unless book&.cover_image&.attached?

      cover_upload_present = (book_attrs[:cover_image] || book_attrs["cover_image"]).present?

      action = :replace if cover_upload_present

      next if action.blank?

      books_plan << { book_id: book.id, action: action, old_blob_id: book.cover_image.blob_id }
    end

    {
      avatar: { action: avatar_action, old_blob_id: @profile.avatar.blob_id },
      books: books_plan
    }
  end

  def purge_replaced_or_removed_uploads(plan)
    if plan[:avatar][:action] == :replace
      purge_old_blob_if_replaced(plan[:avatar][:old_blob_id], @profile.avatar)
    end

    plan[:books].each do |book_plan|
      next unless book_plan[:action] == :replace

      book = @profile.books.find_by(id: book_plan[:book_id])
      next if book.blank?

      purge_old_blob_if_replaced(book_plan[:old_blob_id], book.cover_image)
    end
  end

  def purge_old_blob_if_replaced(old_blob_id, current_attachment)
    return if old_blob_id.blank?
    return unless current_attachment.attached?
    return if current_attachment.blob_id == old_blob_id

    old_blob = ActiveStorage::Blob.find_by(id: old_blob_id)
    return if old_blob.blank?
    return if old_blob.attachments.exists?

    old_blob.purge_later
  end

  def truthy_param?(value)
    ActiveModel::Type::Boolean.new.cast(value)
  end
end
