Rails.application.routes.draw do
  mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql" if Rails.env.development?
  post "/graphql", to: "graphql#execute"

  root "posts#index"

  get "up" => "rails/health#show", as: :rails_health_check

  resources :posts
end
