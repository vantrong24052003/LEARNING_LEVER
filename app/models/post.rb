class Post < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy

  enum :status, { draft: "draft", published: "published", archived: "archived" }

  after_create -> { CacheHelper.clear_pattern(CacheHelper::POSTS_CACHE_KEY) }
  after_update -> { CacheHelper.clear_pattern(CacheHelper::POSTS_CACHE_KEY) }
  after_destroy -> { CacheHelper.clear_pattern(CacheHelper::POSTS_CACHE_KEY) }
end
