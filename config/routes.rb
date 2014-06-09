
Rails.application.routes.draw do
  resources :blog, only: [:index]

  root to: 'blog#index'
end
