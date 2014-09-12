
Rails.application.routes.draw do
  resources :blog, only: [:index]
  resources :posts, except: [:destroy, :index] # :index covered by Blog#index
  resources :users, except: [:destroy]
  resources :sessions, only: [:new, :create, :destroy]

  root to: 'blog#index'
end
