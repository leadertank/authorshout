Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: "users/sessions", masquerades: "users/masquerades" }
  root "home#index"

  resources :profiles, only: [ :show ]
  get "my-profile", to: "profiles#edit", as: :edit_my_profile
  patch "my-profile", to: "profiles#update", as: :my_profile

  resource :billing, only: [ :show ], controller: :billing do
    get :checkout
    get :portal
    post :checkout
    post :portal
  end

  post "books/:book_id/like", to: "book_likes#create", as: :book_like

  namespace :admin do
    get "dashboard", to: "dashboard#index"
    get "sales", to: "sales#index"
    patch "sales/members/:id", to: "sales#update_member", as: :sales_member
    post "sales/products", to: "sales#create_product", as: :sales_products
    patch "sales/products/:id", to: "sales#update_product", as: :sales_product
    resources :users, only: [ :index, :create ]
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
