source "https://rubygems.org"

gem "rails", "8.1.1"
gem "propshaft"
gem "pg", ">= 1.6"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"
gem "bootsnap", require: false
gem "kamal", require: false
gem "thruster", require: false
gem "kaminari"
gem "redis"
gem "ffaker"
gem "graphql"

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: false
  gem "rspec-rails"
  gem "bundler-audit", require: false

  gem "brakeman", require: false

  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "web-console"
  gem "graphiql-rails"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "factory_bot_rails"
end

group :production do
  gem "capistrano"
  gem "capistrano3-puma"
  gem "capistrano-rails", require: false
  gem "capistrano-yarn"
  gem "capistrano-bundler", require: false
  gem "capistrano-rvm"
end
