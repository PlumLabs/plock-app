Rails.application.routes.draw do
  root "dashboard#show"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Authentication
  resource :session
  resources :passwords, param: :token, only: [ :new ]

  resource :dashboard, only: :show, controller: :dashboard
  resources :users, only: [ :index, :new, :create, :destroy ] do
    scope module: "users" do
      resource :profile, only: [ :edit, :update, :destroy ]
    end
  end
  resources :clients, except: [ :show ]
  resources :projects do
    resources :project_assignments, except: [ :index, :show ]
  end
end
