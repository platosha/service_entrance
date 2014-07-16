ServiceEntrance::Application.routes.draw do
  get "exhibits/index"
  get "exhibits/new"
  get "exhibits/edit"
  root "pages#home"
  get "home", to: "pages#home", as: "home"
  get "inside", to: "pages#inside", as: "inside"


  devise_for :users

  namespace :admin do
    root "base#index"
    resources :users
    resources :exhibits
  end

end
