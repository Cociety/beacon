def cociety_url(path = '/', redirect_to = nil)
  cociety = Rails.application.config.cociety
  protocol = cociety[:protocol] == :http ? URI::HTTP : URI::HTTPS
  url = protocol.build(
    host: cociety[:host],
    port: cociety[:port],
    path: path
  )
  url.query = { redirect_to: redirect_to }.to_query if redirect_to
  url.to_s
end

def slack_oath_url(query: {})
  url = protocol.build(
    host: 'slack.com',
    port: 443,
    path: '/oauth/authorize'
  )
  url.query = query
  url.to_s
end

Rails.application.routes.draw do
  devise_for :customers, skip: :all
  direct :avatar do |customer|
    cociety_url("/customer/#{customer.id}/avatar")
  end
  direct :sign_in do
    cociety_url('/customer/sign_in', Current.url)
  end
  direct :sign_out do
    cociety_url('/customer/sign_out', Current.url)
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'home#index'
  resources :trees, only: %i[index show create update] do
    get :settings, action: :show_settings, on: :member
    resources :goals, module: :trees do
      resources :goals, only: %i[new create]
    end
    resource :share, module: :trees
  end
  resources :goals do
    resources :popover, only: %i[index], module: :goals
    resources :comments, only: %i[create], module: :goals
    resources :adopt, only: %i[update], module: :goals
  end
  namespace :goals do
    resources :restore, only: %i[update]
  end
  resources :comments, only: %i[show edit update destroy] do
    resource :actions, module: :comments, only: %i[show]
  end
  resources :attachments, only: %i[destroy]
  namespace :webhooks do
    post :github, to: 'github#create'
  end

  resources :customer, only: %i[index]
  resources :api_keys, only: %i[index create destroy]
  namespace :slack do
    post :event_request
  end
end
