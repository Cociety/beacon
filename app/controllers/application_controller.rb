class ApplicationController < ActionController::Base
  include SetCurrentCustomer

  # https://github.com/CanCanCommunity/cancancan/blob/develop/docs/Changing-Defaults.md
  def current_ability
    @current_ability ||= Ability.new(Current.customer)
  end
end
