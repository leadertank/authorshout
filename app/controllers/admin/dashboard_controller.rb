module Admin
  class DashboardController < BaseController
    def index
      @total_members = User.where(admin: false).count
      @total_admins = User.where(admin: true).count
      @total_books = Book.count
      @total_likes = Book.sum(:likes_count)
      @total_pages = Page.count
      @total_posts = Post.count
      @total_forms = Form.count
      @total_form_submissions = FormSubmission.count
      @paid_form_submissions = FormSubmission.paid.count
      @subscription_forms = Form.subscription.count
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
      @top_books = Book.order(likes_count: :desc, created_at: :desc).limit(10)
      @recent_forms = Form.order(updated_at: :desc).limit(5)
      @recent_form_submissions = FormSubmission.includes(:form).order(created_at: :desc).limit(5)
      @recent_pages = Page.order(updated_at: :desc).limit(5)
      @recent_posts = Post.order(updated_at: :desc).limit(5)
    end
  end
end
