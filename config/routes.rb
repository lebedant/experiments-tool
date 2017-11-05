Rails.application.routes.draw do
  resources :test_variables
  resources :test_parts
  resources :tests
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: "home#index"
end
