
Rails.application.routes.draw do
  resources :blog, only: [:index]
  resources :posts, only: [:new, :create]

  root to: 'blog#index'
end
