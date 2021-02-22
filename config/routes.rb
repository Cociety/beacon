def cociety_url(path = '/')
  cociety = Rails.application.config.cociety
  protocol = cociety[:protocol] == :http ? URI::HTTP : URI::HTTPS
  protocol.build(
    host:  cociety[:host],
    port:  cociety[:port],
    path:  path,
    query: { redirect_to: Current.url }.to_query
  ).to_s
end

Rails.application.routes.draw do
  devise_for :customers, skip: :all
  direct :sign_in do
    cociety_url(Rails.application.config.cociety[:sign_in_path])
  end
  direct :sign_out do
    cociety_url(Rails.application.config.cociety[:sign_out_path])
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'home#index'
  resources :trees, only: %i[index show create] do
    resources :goals, module: :trees
    resource :share, module: :trees
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
