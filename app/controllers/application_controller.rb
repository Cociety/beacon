class ApplicationController < ActionController::Base
  include Pundit, SetCurrentCustomer

  after_action :verify_authorized_or_scoped

  def pundit_user
    Current.customer
  end

  def verify_authorized_or_scoped
    raise Pundit::AuthorizationNotPerformedError unless pundit_policy_authorized? || pundit_policy_scoped?
  end
end
