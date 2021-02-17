Rails.application.routes.draw do
  devise_for :customers, skip: :all
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'trees#index'
  resources :trees, only: %i[index show] do
    resources :goals, module: :trees
  end
  resources :goals do
    resources :popover, only: %i[index], module: :goals
    resources :comments, only: %i[create], module: :goals
    resources :adopt, only: %i[update], module: :goals
  end
  resources :comments, only: %i[show edit update destroy] do
    resource :actions, module: :comments, only: %i[show]
  end
  resources :attachments, only: %i[destroy]
end
