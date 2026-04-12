class PostsController < ApplicationController
  def index
    @posts = Post.published.published_first
  end

  def show
    @post = Post.published.find_by!(slug: params[:slug])
  end
end
