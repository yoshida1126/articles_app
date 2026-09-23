Rails.application.routes.draw do
  root 'main_page#home'

  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    confirmations: 'users/confirmations',
    passwords: 'users/passwords'
  }

  devise_scope :user do
    get 'sign_up', to: 'users/registrations#new'
    post 'sign_up', to: 'users/registrations#create'
    get 'login', to: 'users/sessions#new'
    post 'login', to: 'users/sessions#create'
    delete 'logout', to: 'users/sessions#destroy', as: :logout

    get 'users/:id/edit', to: 'users/registrations#edit', as: :edit_user
    patch 'users/:id', to: 'users/registrations#update', as: :user
    delete '/users/:id', to: 'users/registrations#destroy', as: :delete
  end

  get '/users/account_delete_confirmation', to: 'users#account_delete_confirmation', as: :account_delete_confirmation

  get '/help', to: 'static_pages#help'
  get '/about', to: 'static_pages#about'
  get "search", to: "searches#search"

  get '/trend_articles', to: 'main_page#trend'
  get '/recently_articles', to: 'main_page#recently'

  resources :articles, only: %i[index show destroy] do
    
    member do
      get :liked_users
    end

    resource :likes, only: %i[create destroy]

    resources :article_comments, only: %i[create update destroy], shallow: true do
      resources :article_comment_likes, only: %i[create destroy]
    end
  end

  resources :tags, only: [:show]
  
  resources :users, only: [:show] do
    member do
      get :following
      get :followers
      get :private_articles
      get :drafts
      get :favorite_article_lists
      get :liked_articles
    end

    resources :favorite_article_lists, only: %i[show new create edit update destroy]

    resources :article_drafts, except: [:index, :show] do
      member do
        get :preview
        patch :update_draft
      end

      collection do
        post :save_draft
        post :autosave_draft
        post :commit
      end
    end
  end

  resources :relationships, only: %i[create destroy]
  resources :favorites, only: %i[create destroy]
  resources :favorite_list_bookmarks, only: %i[create destroy]
  
  get "uploads/quota", to: "uploads#remaining_quota"
  post '/upload_images_tracker', to: 'uploads#track_images'
  resources :feedbacks, only: %i[new create]

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

  match '*path', to: 'application#routing_error', via: :all, constraints: lambda { |req|
    !req.path.start_with?('/rails/', '/assets/')
  }
end