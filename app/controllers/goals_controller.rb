class GoalsController < ApplicationController
  before_action :set_goal
  before_action :set_new_parent_goal, only: [:sole_parent]

  def update
    @goal.update! goal_params
    render json: @goal
  end

  def destroy
    @goal.destroy
    render json: @goal
  end

  def sole_parent
    @goal.sole_parent = @new_parent
    @top_level_goal = @goal.tree.top_level_goal
  end

  private

  def set_goal
    @goal = Goal.find(goal_id)
  end

  def goal_id
    params[:id] || params[:goal_id]
  end

  def goal_params
    params.require(:goal).permit :state
  end

  def set_new_parent_goal
    @new_parent = Goal.find(params[:new_parent_id])
  end
end
