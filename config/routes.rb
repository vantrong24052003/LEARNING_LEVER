Rails.application.routes.draw do
  mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql" if Rails.env.development?
  namespace :external do
    resources :letta, only: :create
  end

  post "/graphql", to: "graphql#execute"

  root "home#index"

  get "up" => "rails/health#show", as: :rails_health_check

  resources :dashboards, only: [:index]
  resources :sessions, only: [:new, :create, :destroy]
  resources :posts
end
