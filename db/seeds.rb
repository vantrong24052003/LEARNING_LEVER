# frozen_string_literal: true

# Create 1000 users
Rails.logger.debug "Creating users..."
1000.times do |i|
  User.find_or_create_by!(email: "user#{i + 1}@example.com") do |user|
    user.name = FFaker::Name.name
  end
end

users = User.all

# Create 1000 wallets (one per user)
Rails.logger.debug "Creating wallets..."
users.limit(1000).each do |user|
  Wallet.find_or_create_by!(user:) do |wallet|
    wallet.balance = rand(100..10_000)
  end
end

# Create 1000 posts
Rails.logger.debug "Creating users..."
POST_STATUSES = %w[draft published archived].freeze

Rails.logger.debug "Creating posts..."
post_count = Post.count
(post_count..999).each do
  Post.create!(
    user:   users.sample,
    title:  FFaker::Book.title,
    status: POST_STATUSES.sample,
  )
end

posts = Post.all

# Create 1000 comments
Rails.logger.debug "Creating comments..."
comment_count = Comment.count
(comment_count..999).each do
  Comment.create!(
    post:    posts.sample,
    content: FFaker::Lorem.sentence,
  )
end

Rails.logger.debug { "Total #{User.count} users" }
Rails.logger.debug { "Total #{Wallet.count} wallets" }
Rails.logger.debug { "Total #{Post.count} posts" }
Rails.logger.debug { "Total #{Comment.count} comments" }
