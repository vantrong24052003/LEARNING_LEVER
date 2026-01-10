# frozen_string_literal: true

class DashboardsController < ApplicationController
  def index
    @stats = {
      total_users:    User.count,
      total_posts:    Post.count,
      total_comments: Comment.count,
      active_users:   User.where("created_at > ?", 1.month.ago).count,
    }

    @recent_users = User.order(created_at: :desc).limit(5)
    @recent_posts = Post.order(id: :desc).limit(5)
  end
end
