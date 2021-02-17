class Goals::PopoverController < ApplicationController
  def index
    goal = Goal.find params[:goal_id]
    @goal = authorize goal, :show?
  end
end
