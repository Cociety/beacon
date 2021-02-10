class ApplicationController < ActionController::Base
  include SetCurrentCustomer

  # https://github.com/CanCanCommunity/cancancan/blob/develop/docs/Changing-Defaults.md
  def current_ability
    @current_ability ||= Ability.new(Current.customer)
  end

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json { render nothing: true, status: :not_found }
      format.html { redirect_to main_app.root_url, notice: exception.message, status: :not_found }
      format.js   { render nothing: true, status: :not_found }
    end
  end
end
