class Goals::AdoptController < ApplicationController
  def update
    @goal = authorize Goal.find(params[:goal_id])
    @new_child = authorize Goal.find(params[:id])
    @goal.adopt @new_child
  end
end
