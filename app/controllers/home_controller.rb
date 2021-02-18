class HomeController < ApplicationController
  before_action :skip_authorization
  before_action :redirect_to_trees_if_logged_in

  private

  def redirect_to_trees_if_logged_in
    redirect_to trees_path if customer_signed_in?
  end
end
