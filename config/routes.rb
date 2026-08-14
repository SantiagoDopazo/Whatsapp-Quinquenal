Rails.application.routes.draw do
  get "login", to: "avo_sessions#new", as: :login
  post "login", to: "avo_sessions#create"
  delete "logout", to: "avo_sessions#destroy", as: :logout

  mount_avo
  devise_for :agents, controllers: { sessions: "agents/sessions" }
  resources :agents, only: [ :show ]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
