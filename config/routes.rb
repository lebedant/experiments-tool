# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  devise_for :users

  root to: "home#index"


  resources :test_variables
  resources :test_parts

  resources :tests do
    member do
      get 'copy'
      get 'to_test'
      get 'to_edit'
      get 'to_open'
      get 'to_closed'
    end
  end


  # API routes
  namespace :api, constraints: { format: 'json' } do
    namespace :v1 do
      post '/register_participant', to: 'test_data#register_participant', as: 'api_registration'
      post '/test_data', to: 'test_data#create', as: 'api_test_data'
    end
  end
end
