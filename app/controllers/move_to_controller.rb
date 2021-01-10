class MoveToController < ApplicationController
  before_action :set_goal, only: [:update]

  def update
    @goal.make_child_of(@new_parent)
    render json: @goal.to_json
  end

  def set_goal
    @goal = Goal.find(params[:goal_id])
    @new_parent = Goal.find(params[:id])
  end
end
