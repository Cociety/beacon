class Trees::GoalsController < ApplicationController
  before_action :set_tree

  def new
    @goal = Goal.new
    render partial: '/goals/popover_form', locals: { goal: @goal }
  end

  def create
    @goal = Goal.new goal_params.merge(tree: @tree)
    @goal.parents << @goal.tree.top_level_goal unless @goal.parents.any? && @goal.tree.top_level_goal
    if @goal.save
      redirect_to action: :new
    else
      render partial: '/goals/popover_form', locals: { goal: @goal }
    end
  end

  private

  def set_tree
    @tree = authorize Tree.find(params[:tree_id])
  end

  def goal_params
    params.require(:goal).permit :state, :spent, :duration, :name
  end
end
