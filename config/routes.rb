
Rails.application.routes.draw do
  mount Bootsy::Engine => '/bootsy', as: 'bootsy'
  resources :blog, only: [:index]
  resources :posts, only: [:new, :create]
  resources :users, only: [:new, :create, :show]
  resources :sessions, only: [:new, :create, :destroy]

  root to: 'blog#index'
end
