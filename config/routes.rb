Rails.application.routes.draw do
  resources :test_variables
  resources :test_parts
  resources :tests
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: "home#index"


  namespace :api, constraints: { format: 'json' } do
    namespace :v1 do
      post '/register_participant', to: 'test_data#register_participant', as: 'api_registration'
      post '/test_data', to: 'test_data#create', as: 'api_test_data'
    end
  end
end
