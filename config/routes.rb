
Rails.application.routes.draw do
  resources :blog, only: [:index]
  resources :posts, only: [:new, :create, :show]
  resources :users, only: [:new, :create, :show]
  resources :sessions, only: [:new, :create, :destroy]

  root to: 'blog#index'
end
