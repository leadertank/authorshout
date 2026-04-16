module Admin
  class PostsController < BaseController
    before_action :set_post, only: [:show, :edit, :update, :destroy, :preview]

    def index
      @posts = Post.order(updated_at: :desc)
    end

    def show; end

    def preview
      render "posts/show"
    end

    def new
      @post = Post.new
    end

    def edit; end

    def create
      @post = Post.new(post_params)

      if @post.save
        redirect_to admin_post_path(@post), notice: "Post created successfully."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @post.update(post_params)
        redirect_to admin_post_path(@post), notice: "Post updated successfully."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @post.destroy
      redirect_to admin_posts_path, notice: "Post deleted successfully."
    end

    private

    def set_post
      @post = Post.find_by!(slug: params[:id])
    end

    def post_params
      params.require(:post).permit(:title, :slug, :status, :excerpt, :published_at, :featured_image, :body)
    end
  end
end
