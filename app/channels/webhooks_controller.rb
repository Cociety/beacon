class WebhooksController < ApplicationController
  # Disable CSRF checks since external sites can't send us one
  skip_before_action :verify_authenticity_token
end
