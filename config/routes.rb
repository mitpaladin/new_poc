
Rails.application.routes.draw do
  resources :blog, only: [:index]
  resources :posts, only: [:new, :create]
  resources :users, only: [:new, :create]

  root to: 'blog#index'
end
