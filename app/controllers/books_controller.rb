class BooksController < ApplicationController
  def featured
    @books = Book.public_featured_books
  end
end
