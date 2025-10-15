Rails.application.routes.draw do
  namespace :admin do
    root 'dashboard#index'
    resources :statistics, only: [] do
      collection do
        get 'articles'
        get 'comments'
        get 'users'
        get 'favorite_article_lists'
        get 'tags'
      end
    end
    resources :feedbacks, only: %i[index destroy]
  end

  root 'main_page#home'
  get '/trend_articles', to: 'main_page#trend'
  get '/recentry_articles', to: 'main_page#recently'
  get '/help', to: 'static_pages#help'
  get '/about', to: 'static_pages#about'
  get '/users/account_delete_confirmation', to: 'users#account_delete_confirmation', as: :account_delete_confirmation

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

  resources :article_drafts, only: [:new, :edit] do
    member do
      get :preview, as: :preview
      patch :update_draft, as: :update_draft
      patch :update
      post  :commit, as: :commit
    end

    collection do
      post :save_draft, as: :save_draft
    end
  end

  resources :tags, only: [:show]
  get 'search', to: 'searches#search'
  resources :favorites, only: %i[create destroy]
  resources :favorite_list_bookmarks, only: %i[create destroy]
  
  get "uploads/quota", to: "uploads#remaining_quota"
  post '/upload_article_images_tracker', to: 'uploads#track_article_images'
  post '/upload_comment_images_tracker', to: 'uploads#track_comment_images'

  resources :feedbacks, only: %i[new create]
end
