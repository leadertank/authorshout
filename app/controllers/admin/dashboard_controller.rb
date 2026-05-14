module Admin
  class DashboardController < BaseController
    def index
      @total_members = User.where(admin: false).count
      @total_admins = User.where(admin: true).count
      @total_books = Book.count
      @total_featured_books = Book.where(featured: true).count
      @total_pages = Page.count
      @total_posts = Post.count
      @draft_pages = Page.draft.count
      @scheduled_pages = Page.published.where("published_at > ?", Time.current).count
      @live_pages = Page.live.count
      @draft_posts = Post.draft.count
      @scheduled_posts = Post.published.where("published_at > ?", Time.current).count
      @live_posts = Post.live.count

      @member_growth = User.where(admin: false)
                           .where("created_at >= ?", 14.days.ago)
                           .group("DATE(created_at)")
                           .count

      @book_growth = Book.where("created_at >= ?", 14.days.ago)
                         .group("DATE(created_at)")
                         .count

      @recent_members = User.order(created_at: :desc).limit(10)
  @recent_books = Book.order(created_at: :desc).limit(10)
      @admin_books = Book.admin_submitted.order(created_at: :desc).limit(10)
      @recent_pages = Page.order(updated_at: :desc).limit(5)
      @recent_posts = Post.order(updated_at: :desc).limit(5)
    end
  end
end
