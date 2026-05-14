class HomeController < ApplicationController
  BOOKS_PER_PAGE = 8

  def index
    featured_books = Book.public_featured_books
    @featured_total_pages = total_pages_for(featured_books.size)
    @featured_page = normalized_page(params[:featured_page], @featured_total_pages)
    @featured_books = featured_books.slice((@featured_page - 1) * BOOKS_PER_PAGE, BOOKS_PER_PAGE) || []

    latest_scope = Book.includes(profile: :user)
                       .with_attached_cover_image
                       .where.not(id: featured_books.map(&:id))
                       .order(created_at: :desc)

    @latest_total_books = latest_scope.count
    @latest_total_pages = total_pages_for(@latest_total_books)
    @latest_page = normalized_page(params[:latest_page], @latest_total_pages)
    @books = latest_scope.offset((@latest_page - 1) * BOOKS_PER_PAGE).limit(BOOKS_PER_PAGE)
  end

  private

  def normalized_page(value, total_pages)
    page = value.to_i
    page = 1 if page < 1
    page > total_pages ? total_pages : page
  end

  def total_pages_for(total_items)
    [ (total_items.to_f / BOOKS_PER_PAGE).ceil, 1 ].max
  end
end
