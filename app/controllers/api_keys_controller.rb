class ApiKeysController < ApplicationController

  def index
    @api_keys = policy_scope(ApiKey)
    if session[:load_api_key_id]
      @new_api_key = authorize ApiKey.unscoped.find(session[:load_api_key_id])
      session.delete :load_api_key_id
    end
  end

  def create
    skip_authorization
    @new_api_key = Current.customer.api_keys.create!
    session[:load_api_key_id] = @new_api_key.id
    redirect_to :api_keys
  end

  def destroy
    api_key = authorize ApiKey.find(params[:id])
    api_key.destroy!
    redirect_to :api_keys
  end
end
