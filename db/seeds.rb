# Create 100 users
puts "Creating users..."
100.times do |i|
  User.find_or_create_by!(email: "user#{i + 1}@example.com") do |user|
    user.name = FFaker::Name.name
  end
end

users = User.all

# Create 100 wallets (one per user)
puts "Creating wallets..."
users.limit(100).each do |user|
  Wallet.find_or_create_by!(user: user) do |wallet|
    wallet.balance = rand(100..10000)
  end
end

# Create 100 posts
puts "Creating posts..."
post_count = Post.count
(post_count..99).each do
  Post.create!(
    user: users.sample,
    title: FFaker::Book.title,
    status: ["draft", "published", "archived"].sample
  )
end

posts = Post.all

# Create 100 comments
puts "Creating comments..."
comment_count = Comment.count
(comment_count..99).each do
  Comment.create!(
    post: posts.sample,
    content: FFaker::Lorem.sentence
  )
end

puts "Total #{User.count} users"
puts "Total #{Wallet.count} wallets"
puts "Total #{Post.count} posts"
puts "Total #{Comment.count} comments"
