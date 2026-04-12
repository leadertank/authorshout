module Admin
  class DashboardController < BaseController
    def index
      @total_members = User.where(admin: false).count
      @total_admins = User.where(admin: true).count
      @total_books = Book.count
      @total_likes = Book.sum(:likes_count)
      @total_pages = Page.count
      @total_posts = Post.count

      @member_growth = User.where(admin: false)
                           .where("created_at >= ?", 14.days.ago)
                           .group("DATE(created_at)")
                           .count

      @book_growth = Book.where("created_at >= ?", 14.days.ago)
                         .group("DATE(created_at)")
                         .count

      @recent_members = User.order(created_at: :desc).limit(10)
      @top_books = Book.order(likes_count: :desc, created_at: :desc).limit(10)
      @recent_pages = Page.order(updated_at: :desc).limit(5)
      @recent_posts = Post.order(updated_at: :desc).limit(5)
    end
  end
end
