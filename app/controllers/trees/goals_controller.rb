class Trees::GoalsController < ApplicationController
  before_action :set_tree

  def new
    @goal = Goal.new
  end

  def create
    @goal = Goal.new goal_params.merge(tree: @tree)
    @goal.parents << @goal.tree.top_level_goal if @goal.tree.top_level_goal && @goal.parents.empty?
    if @goal.save
      @goal.assign_to Current.customer
      redirect_to @goal.tree
    else
      render :new
    end
  end

  private

  def set_tree
    @tree = authorize Tree.find(params[:tree_id]), :edit?
  end

  def goal_params
    params.require(:goal).permit :state, :spent, :duration, :name
  end
end
