class PostsController < ApplicationController
  DEFAULT_LIMIT = 50

  before_action :find_post, only: [:show, :update, :destroy]

  def create
    @post = Post.new(permit_params)

    if @post.save
      render_success(response: @post, status: :created)
    else
      render_error(error: @post.errors.full_messages.join(", "), status: :unprocessable_entity)
    end
  end

  def index
    @posts = Post.page(params[:page]).per(params[:limit] || DEFAULT_LIMIT)
    render_success(response: @posts, status: :ok)
  end

  def show
    render_success(response: @post, status: :ok)
  end

  def update
    if @post.update(permit_params)
      render_success(response: @post, status: :ok)
    else
      render_error(error: @post.errors.full_messages.join(", "), status: :unprocessable_entity)
    end
  end

  def destroy
    if @post&.destroy
      render_success(response: { message: "Post deleted successfully" }, status: :ok)
    else
      render_error(error: "Post not found or could not be deleted", status: :not_found)
    end
  end

  private

  def find_post
    @post = Post.find_by(id: params[:id])
  end

  def permit_params
     params.require(:post).permit(:user_id, :title, :status)
  end
end
