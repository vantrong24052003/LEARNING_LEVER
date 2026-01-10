module External
  class LocalQuery
    def search(query:, category: nil, limit: nil)
      posts = Post.all

      status_from_query = Post.statuses.keys.find { |s| s.casecmp?(query.to_s) }
      if status_from_query
        posts = posts.where(status: status_from_query)
      elsif query.present?
        posts = posts.where("title ILIKE ?", "%#{query}%")
      end

      posts = posts.where(status: category) if category.present? && Post.statuses.key?(category)

      posts = posts.limit(limit) if limit.present?

      posts.map do |post|
        { id: post.id, title: post.title, status: post.status, user_name: post.user&.name, created_at: post.created_at }
      end
    end
  end
end
