class GoalsController < ApplicationController
  before_action :set_goal
  before_action :set_new_child_goal, only: [:adopt]

  def show; end

  def edit; end

  def update
    @goal.update! goal_params
    render json: @goal
  end

  def destroy
    @goal.destroy
    render json: @goal
  end

  private

  def set_goal
    @goal = authorize Goal.find(params[:id])
  end

  def goal_params
    params.require(:goal).permit :state, :spent, :duration, :name, :tree_id, attachments: []
  end
end
