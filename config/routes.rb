Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  root "home#index"
  
  #dashboard des prestataires
  get 'dashboard/provider', to: 'dashboards#provider', as: :dashboard_provider
  get 'dashboard/provider/export', to: 'dashboards#export_data', as: :dashboard_provider_export
  


  
  # Ressource provider unique par user
  #permet de definir le profil du prestataire
  resource :provider, only: [:new, :create, :show, :edit, :update,:destroy]
 
  
  # Routes publiques (client)
    #namespace :customer do
   # resources :reservations, only: [:index, :show, :edit, :update] do 
    #  member do
     #   patch :pay
      #end
    #end 
  #end
  namespace :customer do
    resources :hotels, only: [:index, :show] do 
      resources :rooms, only: [:index, :show] do
        resources :bookings, only: [:new, :create]
      end
    end
    resources :trips, only: [:index, :show] do
      resources :bookings, only: [:new, :create]
    end
    resources :cars, only: [:index, :show] do
      resources :bookings, only: [:new, :create]
    end
    resources :reservations, only: [:index, :show, :edit, :update] do 
      resources :payments, only: [:new, :create, :show]
      post 'webhook', on: :collection

     
    end 
    get "/menu", to: "menu#index", as: :menu_customer
  end
  
  # Namespace prestataire (provider) pour creer les services(hotels-room,car,trip)
  namespace :provider do
    resources :hotels do 
      delete 'purge_image/:id', to: 'hotels#purge_image', as: :purge_image
      resources :rooms
    end
    resources :cars
    resources :trips 
    resources :reservations, only: [:index, :update]
  end
  
end
