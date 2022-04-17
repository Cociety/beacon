# :nodoc:
class TreesController < ApplicationController
  before_action :set_tree, only: [:show]

  def index
    @tree = authorize Tree.new, :create?
    @trees = policy_scope(Tree)
  end

  def show
    redirect_to goal_url(@tree.top_level_goal)
  end

  def create
    authorize Tree
    @tree = Tree.create!
    @tree.goals.create! name: 'New tree', top_level: true
    Current.customer.add_role :writer, @tree
    redirect_to action: :show, id: @tree.id
  rescue => e
    Rails.logger.info e
    flash[:alert] = 'Failed to create a new tree'
    redirect_to :trees
  end

  private

  def set_tree
    @tree = authorize Tree.find(params[:id])
  end
end
