# :nodoc:
class Trees::GoalsController < ApplicationController
  before_action :set_tree, :set_parent_goal

  def new
    @goal = Goal.new
  end

  def create
    @goal = Goal.new goal_params.merge(tree: @tree)
                                .merge(parents: [parent])

    if @goal.save
      @goal.assign_to Current.customer
      redirect_to @goal.parents.first
    else
      render :new
    end
  end

  private

  def set_tree
    @tree = authorize Tree.find(params[:tree_id]), :edit?
  end

  def set_parent_goal
    @parent_goal = Goal.find_by(id: params[:goal_id]) if params[:goal_id].present?
    authorize @parent_goal, :show? if @parent_goal
  end

  def goal_params
    params.require(:goal).permit :state, :spent, :duration, :name
  end

  def parent
    @parent_goal || @tree.top_level_goal
  end
end
