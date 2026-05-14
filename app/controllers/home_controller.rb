class HomeController < ApplicationController
  def index
    all_books_scope = Book.includes(:book_likes, profile: :user).with_attached_cover_image
    featured_candidates = all_books_scope.where(featured: true).order(created_at: :desc).to_a
    @featured_books = featured_candidates.select do |book|
      book.submitted_by_admin? || book.user&.paid_member? || book.user&.featured_author?
    end

    latest_scope = all_books_scope.where.not(id: @featured_books.map(&:id)).order(created_at: :desc)

    @per_page = 8
    @total_books = latest_scope.count
    @total_pages = [ (@total_books.to_f / @per_page).ceil, 1 ].max
    @page = params[:page].to_i
    @page = 1 if @page < 1
    @page = @total_pages if @page > @total_pages

    @books = latest_scope.offset((@page - 1) * @per_page).limit(@per_page)
  end
end
