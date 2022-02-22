# :nodoc:
class TreesController < ApplicationController
  before_action :set_tree, only: [:show, :update, :show_settings]

  def index
    @trees = policy_scope(Tree)
    @tree = Tree.new
  end

  def show
    redirect_to goal_url(@tree.top_level_goal)
  end

  def show_settings
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

  def update
    @tree.update! tree_params
    flash[:notice] = 'Saved!'
    redirect_to @tree.top_level_goal
  rescue => e
    Rails.logger.info e
    render :show_settings
  end

  private

  def set_tree
    @tree = authorize Tree.find(params[:id])
  end

  def tree_params
    params.require(:tree).permit(:slack_webhook_url)
  end
end
