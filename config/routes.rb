Rails.application.routes.draw do
  constraints(host: "www.authorshout.com") do
    match "(*path)", to: redirect(status: 301) { |_params, request|
      "https://authorshout.com#{request.fullpath}"
    }, via: :all
  end

  post "webhooks/stripe", to: "pay/webhooks/stripe#create"

  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations",
    masquerades: "users/masquerades"
  }
  root "home#index"
  get "products", to: "products#show", as: :products

  get "membership", to: "membership#show", as: :membership
    get "book-awards", to: "awards_submissions#new", as: :new_awards_submission
    post "book-awards", to: "awards_submissions#create", as: :awards_submissions
    get "book-awards/success/:token", to: "awards_submissions#success", as: :awards_submission_success
  get "social-media-book-blitz", to: "social_media_blitz_submissions#new", as: :new_social_media_blitz_submission
  post "social-media-book-blitz", to: "social_media_blitz_submissions#create", as: :social_media_blitz_submissions
  get "social-media-book-blitz/success/:token", to: "social_media_blitz_submissions#success", as: :social_media_blitz_submission_success
  get "authors/featured", to: "authors#featured", as: :featured_authors
  get "authors/directory", to: "authors#directory", as: :authors_directory
  resource :support, only: [ :new, :create ], controller: :support_requests

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
    resources :users, only: [ :index, :create, :destroy ] do
      member do
        patch :toggle_featured_author
      end
    end
    resources :submissions, only: [ :index, :destroy ], controller: :awards_submissions do
      collection do
        delete :delete_non_paid
      end
    end
    resources :books, only: [ :new, :create, :edit, :update, :destroy ]
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
