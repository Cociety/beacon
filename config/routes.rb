Rails.application.routes.draw do
  devise_for :customers, skip: :all
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'home#index'
  resources :goals, only: %i[update destroy] do
    resources :popover, only: %i[index]
    match 'adopt/:new_child_id', action: :adopt, via: %i[put patch]
  end
end
