class TreesController < ApplicationController
  def index
    @trees = policy_scope(Tree)
    @tree = Tree.new
  end

  def show
    @tree = authorize Tree.find(params[:id])
    @show_completed_goals = ActiveRecord::Type::Boolean.new.deserialize(params[:show_completed_goals])
  end

  def create
    authorize Tree
    @tree = Tree.create
    Current.customer.add_role :writer, @tree
    redirect_to action: :show, id: @tree.id
  end
end
