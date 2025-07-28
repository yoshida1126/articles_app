Rails.application.routes.draw do
  get 'favorite_list_bookmarks/create'
  get 'favorite_list_bookmarks/destroy'
  root 'main_page#home'
  get '/trend_articles', to: 'main_page#trend'
  get '/recentry_articles', to: 'main_page#recentry'
  get '/tagid/articles', to: 'main_page#trend_tag_articles'
  get '/help', to: 'static_pages#help'
  get '/about', to: 'static_pages#about'
  get '/users/check', to: 'users#check', as: :user_delete_check

  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    confirmations: 'users/confirmations',
    passwords: 'users/passwords'
  }
  devise_scope :user do
    get 'sign_up', to: 'users/registrations#new'
    post 'sign_up', to: 'users/registrations#create'
    get 'users/:id/edit', to: 'users/registrations#edit', as: :edit_user
    patch 'users/:id', to: 'users/registrations#update', as: :user
    delete '/users/:id', to: 'users/registrations#destroy', as: :delete

    get 'login', to: 'users/sessions#new'
    post 'login', to: 'users/sessions#create'
    delete 'logout', to: 'users/sessions#destroy', as: :logout
  end
  resources :users do
    member do
      get :following, :followers
    end
    resources :favorite_article_lists, only: %i[index show new create edit update destroy]
  end
  get '/users/:id', to: 'users#show'
  resources :relationships, only: %i[create destroy]
  resources :articles, only: %i[index show new create edit update destroy] do
    resource :likes, only: %i[create destroy]
    resources :article_comments, only: %i[create destroy edit update] do
      resource :article_comment_likes, only: %i[create destroy]
    end
  end
  resources :tags, only: [:show]
  get 'search' => 'searches#search'
  resources :favorites, only: %i[create destroy]
end
