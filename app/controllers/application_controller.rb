class ApplicationController < ActionController::Base
  include Pundit, SetCurrentCustomer

  after_action :verify_authorized_or_scoped
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from ActiveRecord::RecordNotFound, with: :user_not_authorized

  def pundit_user
    Current.customer
  end

  private

  def user_not_authorized
    redirect_to root_path
  end

  def verify_authorized_or_scoped
    raise Pundit::AuthorizationNotPerformedError unless pundit_policy_authorized? || pundit_policy_scoped?
  end
end
