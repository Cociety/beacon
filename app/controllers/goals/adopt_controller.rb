class Goals::AdoptController < ApplicationController
  before_action :set_goal
  before_action :set_new_child_goal

  def update
    @goal.adopt @new_child
  end

  private

  def set_goal
    @goal = Goal.find(params[:goal_id])
  end

  def set_new_child_goal
    @new_child = Goal.find(params[:id])
  end
end
