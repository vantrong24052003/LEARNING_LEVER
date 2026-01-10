# frozen_string_literal: true

set :stage, :production
set :rails_env, :production
set :branch, "main"

# user ssh , server ssh
server "16.171.55.15", user: "deploy", roles: %w[app db web]
