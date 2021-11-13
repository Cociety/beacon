# :nodoc:
class Goals::AdoptController < ApplicationController
  def update
    @goal = authorize Goal.find(params[:goal_id])
    @new_child = authorize Goal.find(params[:id])
    @goal.toggle_adoption @new_child
    redirect_to @goal
  end
end
