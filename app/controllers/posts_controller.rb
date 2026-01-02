class PostsController < ApplicationController
  DEFAULT_PAGE = 1
  DEFAULT_LIMIT = 50
  DEFAULT_TTL = 30

  before_action :find_post, only: [ :update, :destroy ]

  def create
    @post = Post.new(permit_params)

    if @post.save
      render_success(response: @post, status: :created)
    else
      render_error(error: @post.errors.full_messages.join(", "), status: :unprocessable_entity)
    end
  end

  def index
    page  = params[:page].presence || DEFAULT_PAGE
    limit = params[:limit].presence || DEFAULT_LIMIT
    key   = "posts:index:page:#{page}:limit:#{limit}"

    posts = cache_fetch(key, ttl: DEFAULT_TTL) do
      Post.order(:id).page(page).per(limit).as_json
    end

    render_success(response: posts, status: :ok)
  end

  # def show
  #   render_success(response: @post, status: :ok)
  # end

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
