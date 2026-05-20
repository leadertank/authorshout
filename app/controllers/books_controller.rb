class BooksController < ApplicationController
  BOOKS_PER_PAGE = 20

  def featured
    featured_books = Book.public_featured_books
    @featured_total = featured_books.size
    @total_pages = total_pages_for(@featured_total)
    @page = normalized_page(params[:page], @total_pages)
    @books = featured_books.slice((@page - 1) * BOOKS_PER_PAGE, BOOKS_PER_PAGE) || []
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
