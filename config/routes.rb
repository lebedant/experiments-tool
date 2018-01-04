# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  devise_for :users

  root to: "home#index"

  resources :chart_queries, only: [:create, :destroy]

  resources :experiments do
    member do
      get 'copy'
      get 'to_debug'
      get 'to_edit'
      get 'to_open'
      get 'to_closed'
    end
  end

  # API routes
  namespace :api, constraints: { format: 'json' } do
    namespace :v1 do
      post '/register_participant', to: 'experiment_data#register_participant', as: 'api_registration'
      post '/save_data', to: 'experiment_data#create', as: 'api_test_data'
    end
  end
end
