Rails.application.routes.draw do
  devise_for :customers, skip: :all
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'trees#index'
  resources :trees, only: %i[index show]
  resources :goals do
    resources :popover, only: %i[index]
    resources :comments, only: %i[create]
    match 'adopt/:new_child_id', action: :adopt, via: %i[put patch]
  end
  resources :comments, only: %i[show edit update destroy] do
    resource :actions, module: :comments, only: %i[show]
  end
  resources :attachments, only: %i[destroy]
end
