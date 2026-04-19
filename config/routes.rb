Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: "users/sessions" }
  root "home#index"

  resources :profiles, only: [:show]
  get "my-profile", to: "profiles#edit", as: :edit_my_profile
  patch "my-profile", to: "profiles#update", as: :my_profile

  post "books/:book_id/like", to: "book_likes#create", as: :book_like

  namespace :admin do
    get "dashboard", to: "dashboard#index"
    resources :users, only: [:index]
    resources :forms do
      resources :submissions, controller: "form_submissions", only: [:index, :show] do
        collection do
          get :export
        end
      end
    end
    resources :pages do
      member do
        get :preview
      end
    end
    resources :posts do
      member do
        get :preview
      end
    end
  end

  resources :forms, only: [:show], param: :slug do
    post :submit, on: :member, to: "form_submissions#create"
  end
  get "forms/:form_slug/submissions/:token/complete", to: "form_submissions#complete", as: :form_submission_complete
  get "forms/:form_slug/submissions/:token/cancel", to: "form_submissions#cancel", as: :form_submission_cancel

  get "blog", to: "posts#index", as: :posts
  get "blog/:slug", to: "posts#show", as: :post
  get "pages/:slug", to: "pages#show", as: :page

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

end
