
Rails.application.routes.draw do
  resources :posts, except: [:destroy] do

  end
  resources :users, except: [:destroy]
  resources :sessions, only: [:new, :create, :destroy]

  root to: 'posts#index'
end
