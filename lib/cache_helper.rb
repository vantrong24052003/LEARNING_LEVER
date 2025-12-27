# frozen_string_literal: true

module CacheHelper
  POSTS_CACHE_KEY = "posts:index:*"

  def cache_fetch(key, ttl: 60)
    cached = REDIS.get(key)
    if cached
      Rails.logger.info("CACHE HIT #{key}")
      return JSON.parse(cached)
    end

    Rails.logger.info("CACHE MISS #{key}")
    value = yield
    REDIS.setex(key, ttl, value.to_json)
    value
  end

  module_function

  def clear_pattern(pattern)
    keys = REDIS.keys(pattern)
    return if keys.empty?

    REDIS.del(*keys)
    Rails.logger.info("CACHE CLEARED: #{pattern} (#{keys.size} keys)")
  end
end
