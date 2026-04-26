module Admin
  class PostsController < BaseController
    before_action :set_post, only: [ :show, :edit, :update, :destroy, :preview ]
    before_action :load_taxonomy, only: [ :index, :new, :edit, :create, :update ]

    def index
      @filters = post_filters
      @posts = Post.includes(:post_category, :post_tags).order(updated_at: :desc)
      @posts = @posts.filter_by_state(@filters[:state])
      @posts = @posts.search_query(@filters[:query]) if @filters[:query].present?
      @posts = @posts.where(post_category_id: @filters[:post_category_id]) if @filters[:post_category_id].present?
      @posts = @posts.joins(:post_tags).where(post_tags: { id: @filters[:post_tag_id] }).distinct if @filters[:post_tag_id].present?
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
      params.require(:post).permit(:title, :slug, :status, :excerpt, :published_at, :featured_image, :body, :post_category_id, :category_name, :tag_list)
    end

    def post_filters
      params.permit(:query, :state, :post_category_id, :post_tag_id)
    end

    def load_taxonomy
      @post_categories = PostCategory.alphabetical
      @post_tags = PostTag.alphabetical
    end
  end
end
