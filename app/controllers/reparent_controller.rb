class ReparentController < ApplicationController
  before_action :set_goal, only: [:update]

  def update
    @goal.make_sole_parent(@new_parent)
    @top_level_goal = @goal.tree.top_level_goal
  end

  def set_goal
    @goal = Goal.find(params[:goal_id])
    @new_parent = Goal.find(params[:id])
  end
end
