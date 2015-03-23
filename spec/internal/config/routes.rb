Rails.application.routes.draw do
  resources :users do
    member do
      get :double_init
      get :show_ajax
      get :email_field
      get :event_type
    end
  end

  namespace :cuca do
    resources :cars
  end

  namespace :admin do
    resources :users
  end

  root :to => "users#index"
end
