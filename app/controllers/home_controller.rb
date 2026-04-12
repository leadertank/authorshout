class HomeController < ApplicationController
  def index
    @books = Book.includes(profile: :user).with_attached_cover_image.order(created_at: :desc)
  end
end
