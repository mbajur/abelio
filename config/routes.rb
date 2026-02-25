Rails.application.routes.draw do
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

    root to: "dashboard#index"
  end
end
