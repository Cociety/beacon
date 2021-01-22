Rails.application.routes.draw do
  devise_for :customers, skip: :all
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'home#index'
  resources :goals, only: [:destroy] do
    match 'sole_parent/:new_parent_id', action: :sole_parent, via: %i[put patch]
  end
end
