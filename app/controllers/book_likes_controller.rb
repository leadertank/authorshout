class BookLikesController < ApplicationController
  before_action :set_book

  def create
    like = if user_signed_in?
      @book.book_likes.new(user: current_user)
    else
      @book.book_likes.new(visitor_token: current_visitor_token)
    end

    if like.save
      redirect_back fallback_location: root_path, notice: "Thanks for liking this book!"
    else
      redirect_back fallback_location: root_path, alert: "You already liked this book."
    end
  end

  private

  def set_book
    @book = Book.find(params[:book_id])
  end
end
