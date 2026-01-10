# frozen_string_literal: true

source "https://rubygems.org"

gem "bootsnap", require: false
gem "faraday", "2.14"
gem "ffaker"
gem "graphql"
gem "importmap-rails"
gem "jbuilder"
gem "kamal", require: false
gem "kaminari"
gem "pg", ">= 1.6"
gem "propshaft"
gem "puma", ">= 5.0"
gem "rails", "8.0.4"
gem "redis"
gem "solid_cable"
gem "solid_cache"
gem "solid_queue"
gem "stimulus-rails"
gem "thruster", require: false
gem "turbo-rails"
gem "tzinfo-data", platforms: %i[windows jruby]

group :development, :test do
  gem "bundler-audit", require: false
  gem "debug", platforms: %i[mri windows], require: false
  gem "rspec-rails"

  gem "brakeman", require: false

  gem "rubocop-capybara", require: false
  gem "rubocop-factory_bot", require: false
  gem "rubocop-graphql", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rails-omakase", require: false
  gem "rubocop-rspec", require: false
  gem "rubocop-rspec_rails", require: false
end

group :development do
  gem "graphiql-rails"
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "factory_bot_rails"
  gem "selenium-webdriver"
end

group :production do
  gem "capistrano"
  gem "capistrano3-puma"
  gem "capistrano-bundler", require: false
  gem "capistrano-rails", require: false
  gem "capistrano-rvm"
  gem "capistrano-yarn"
end
