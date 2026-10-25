require "uri"

Rails.application.routes.draw do
  direct :external_game do |slug, options|
    URI::HTTPS.build(
      host: Rails.configuration.x.external_games.host,
      path: "/games/#{slug}",
      query: options&.slice(:token)&.to_query.presence
    ).to_s
  end

  namespace :admin do
    resource :session
    resources :passwords, param: :token
    resources :games
    resources :schools do
      resources :students, shallow: true, except: [ :show ]
      resources :classrooms, shallow: true, except: %i[destroy show] do
        member { get :schedule }
      end
      resources :teachers, shallow: true, except: [ :show ]
      get :csv_template, to: "csv#download"
      post :csv_import, to: "csv#import"
    end
    resources :content_modules, except: [ :show ] do
      resources :links, shallow: true, except: %i[index show]
    end
    resources :classroom_modules, only: %i[update]
  end

  resource :student_session, only: %i[new create destroy]
  resources :student_homes, only: %i[index]
  resources :games, only: [] do
    member do
      get :play, to: "game_landing#show"
    end
  end
  resources :classroom_rosters, only: %i[show], param: :uuid
  resources :game_attempts, only: [] do
    collection do
      post :start
      post :finish
      match :start, via: :options, action: :preflight, as: nil
      match :finish, via: :options, action: :preflight, as: nil
    end
  end

  root to: "admin/schools#index"

  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
