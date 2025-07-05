Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  root "home#index"
  # Defines the root path route ("/")
  # root "posts#index"
  get "dashboard/provider", to: "dashboards#provider", as: :dashboard_provider
  resource :provider, only: [:new, :create, :show, :edit, :update,:destroy]
  resources :hotels do 
    resources :rooms
  end

  resources :cars
  resources :trips
  
end
