# frozen_string_literal: true

module ServiceTools
  class PostFinder
    def execute(author_name: nil, keyword: nil, limit: 10, status: nil)
      query = Post.all

      query = query.joins(:user).where("users.name ILIKE ?", "%#{author_name}%") if author_name.present?

      query = query.where("posts.title ILIKE ?", "%#{keyword}%") if keyword.present?

      query = query.where(status: status) if status.present?

      results = query.limit(limit)

      results.map do |post|
        {
          title: post.title,
          status: post.status,
          author: post.user&.name || "Unknown",
          created_at: post.created_at.strftime("%Y-%m-%d")
        }
      end
    rescue StandardError => e
      { error: "Post search failed: #{e.message}" }
    end
  end
end
