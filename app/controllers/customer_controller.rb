class CustomerController < ApplicationController

  def index
    skip_authorization
    @slack_client_id = Rails.application.credentials.dig(:slack, :client_id)
  end
end
