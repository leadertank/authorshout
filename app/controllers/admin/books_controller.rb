module Admin
  class BooksController < BaseController
    before_action :set_book, only: [ :edit, :update, :destroy ]

    def index
      @admin_books = Book.admin_submitted.order(featured: :desc, created_at: :desc)
    end

    def new
      @book = Book.new
    end

    def create
      @book = Book.new(book_params)
      @book.admin_submitted = true
      if @book.save
        redirect_to admin_dashboard_path, notice: "Book was successfully added."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      @book.admin_submitted = true
      if @book.update(book_params)
        redirect_to admin_dashboard_path, notice: "Book was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @book.destroy
      redirect_to admin_dashboard_path, notice: "Book was successfully deleted."
    end

    private

    def set_book
      @book = Book.admin_submitted.find(params[:id])
    end

    def book_params
      params.require(:book).permit(:title, :author_name, :cover_image, :cover_image_url, :purchase_url, :featured)
    end
  end
end
