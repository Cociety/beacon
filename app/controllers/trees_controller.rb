# :nodoc:
class TreesController < ApplicationController
  def index
    @trees = policy_scope(Tree)
    @tree = Tree.new
  end

  def show
    @tree = authorize Tree.find(params[:id])
    redirect_to goal_url(@tree.top_level_goal)
  end

  def create
    authorize Tree
    @tree = Tree.create
    @tree.goals << Goal.new(name: 'New tree')
    Current.customer.add_role :writer, @tree
    redirect_to action: :show, id: @tree.id
  end
end
