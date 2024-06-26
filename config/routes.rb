Rails.application.routes.draw do
  root 'main_page#home'
  get "/help", to: "static_pages#help"
  get "/about", to: "static_pages#about"
  get "/users/:id", to: "users#show" 
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    confirmations: 'users/confirmations',
    passwords: 'users/passwords'
  }, skip: [:registrations, :sessions]
  devise_scope :user do 
    get 'sign_up', to: 'users/registrations#new'
    post 'sign_up', to: 'users/registrations#create' 
    get 'users/:id/edit', to: 'users/registrations#edit', as: :edit_user
    patch 'users/:id', to: 'users/registrations#update', as: :user 

    get 'login', to: 'users/sessions#new'
    post 'login', to: 'users/sessions#create' 
    delete 'logout', to: 'users/sessions#destroy', as: :logout
  end
end
