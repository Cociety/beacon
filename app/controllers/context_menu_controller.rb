class ContextMenuController < ApplicationController
  before_action :set_goal, only: [:index]

  def set_goal
    @goal = Goal.find(params[:goal_id])
  end
end