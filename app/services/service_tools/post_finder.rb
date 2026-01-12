# frozen_string_literal: true

module ServiceTools
  class PostFinder < BaseTool
    ALLOWED_TABLES = %w[posts users].freeze
    ALLOWED_COLUMNS = %w[id title status author created_at].freeze

    def execute(author_name: nil, keyword: nil, limit: 10, status: nil)
      validate_table!("posts", ALLOWED_TABLES)
      validate_column!("author", ALLOWED_COLUMNS) if author_name.present?
      validate_column!("title", ALLOWED_COLUMNS) if keyword.present?
      validate_column!("status", ALLOWED_COLUMNS) if status.present?

      limit = [limit.to_i, 50].min

      query = Post.includes(:user)
      query = query.joins(:user).where("users.name ILIKE ?", "%#{author_name}%") if author_name.present?
      query = query.where("posts.title ILIKE ?", "%#{keyword}%") if keyword.present?
      query = query.where(status: status) if status.present?

      query.limit(limit).map do |post|
        {
          id: post.id,
          title: post.title,
          status: post.status,
          author: post.user&.name,
          created_at: post.created_at.strftime("%Y-%m-%d")
        }.select { |k, _| ALLOWED_COLUMNS.include?(k.to_s) }
      end
    end
  end
end
