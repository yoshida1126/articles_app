Rails.application.routes.draw do
  get "/signup", to: "users#new"
  get "/help", to: "static_pages#help"
  get "/about", to: "static_pages#about"
  root 'main_page#home'
end
