class CustomerController < ApplicationController

  def index
    @api_keys = policy_scope(ApiKey)
  end
end
