module External
  class LocalQuery
    DEFAULT_LIMIT = 10

    def search(query:, category: nil)
      posts = Post.all
      posts = posts.where(status: category) if Post.statuses.key?(category)
      posts = posts.where("title ILIKE ?", "%#{query}%") if query.present?
      
      posts.limit(DEFAULT_LIMIT).map do |post|
        { id: post.id, title: post.title, status: post.status, user_name: post.user&.name, created_at: post.created_at }
      end
    end
  end
end
