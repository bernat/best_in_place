BipApp::Application.routes.draw do
  resources :users do
    member do
      put :test_respond_with
      get :double_init
      get :show_ajax
      get :email_field
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
