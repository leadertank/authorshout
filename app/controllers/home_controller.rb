class HomeController < ApplicationController
  def index
    books_scope = Book.includes(:book_likes, profile: :user).with_attached_cover_image.order(created_at: :desc)

    @per_page = 8
    @total_books = books_scope.count
    @total_pages = [ (@total_books.to_f / @per_page).ceil, 1 ].max
    @page = params[:page].to_i
    @page = 1 if @page < 1
    @page = @total_pages if @page > @total_pages

    @books = books_scope.offset((@page - 1) * @per_page).limit(@per_page)
  end
end
