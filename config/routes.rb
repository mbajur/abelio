authenticated_session = lambda do |req|
  session_id = ActionDispatch::Cookies::CookieJar.build(req, req.cookies).signed[:session_id]
  session_id.present? && Session.exists?(id: session_id)
end

Rails.application.routes.draw do
  constraints authenticated_session do
    mount SolidErrors::Engine, at: "/solid_errors"
  end

  mount Federails::Engine => "/"

  resource :session
  resources :passwords, param: :token

  get "up" => "rails/health#show", as: :rails_health_check

  namespace :panel do
    resources :posts, only: %i[show new create edit update] do
      resources :blocks, only: %i[create destroy] do
        post :refresh, on: :member
      end
    end

    resources :activities, only: %i[index], path: :activity
    resource :settings, only: %i[edit update]

    namespace :blog do
      resources :posts, only: [ :index ]
      resources :drafts, only: [ :index ]
      resources :templates, except: [ :show ]

      root to: redirect("panel/blog/posts")
    end

    resources :blocks, only: %i[update]

    namespace :block do
      resources :images, only: %i[create destroy]
    end

    get :search, to: "search#index"

    # Other users resources
    resources :actors, only: %i[show], path: :u, param: :id, constraints: { id: /[^\/]+/ }, format: false do
      post :follow, on: :member
      delete :unfollow, on: :member
    end

    root to: "dashboard#index"
  end

  resources :posts, path: :posts, controller: "public/posts", only: [ :index, :show ]
  root to: "public/posts#index"
end
