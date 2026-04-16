class PostsController < ApplicationController
  def index
    @posts = Post.includes(:post_category, :post_tags).live.published_first
  end

  def show
    @post = Post.includes(:post_category, :post_tags).live.find_by!(slug: params[:slug])
  end
end
