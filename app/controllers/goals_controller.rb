class GoalsController < ApplicationController
  before_action :set_goal
  before_action :set_new_child_goal, only: [:adopt]

  def update
    @goal.update! goal_params
    render json: @goal
  end

  def destroy
    @goal.destroy
    render json: @goal
  end

  def adopt
    @goal.adopt @new_child
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
    params.require(:goal).permit :state, :spent, :duration
  end

  def set_new_child_goal
    @new_child = Goal.find(params[:new_child_id])
  end
end
