BipApp::Application.routes.draw do
  resources :users do
    member do
      put :test_respond_with
      get :double_init
    end
  end

  namespace :cuca do
    resources :cars
  end

  root :to => "users#index"
end
