class PostsController < ApplicationController
  def index
    @posts = Post.live.published_first
  end

  def show
    @post = Post.live.find_by!(slug: params[:slug])
  end
end
