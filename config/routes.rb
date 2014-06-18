
Rails.application.routes.draw do
  resources :blog, only: [:index]
  resources :posts, only: [:new]

  root to: 'blog#index'
end
