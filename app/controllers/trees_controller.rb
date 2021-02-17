class TreesController < ApplicationController
  def index
    @trees = policy_scope(Tree)
  end

  def show
    @tree = authorize Tree.find(params[:id])
  end
end
