class PopoverController < ApplicationController
  before_action :set_goal, only: [:index]
  before_action :authorize

  def set_goal
    @goal = Goal.find(params[:goal_id])
  end

  def authorize
    authorize! :read, @goal
  end
end
