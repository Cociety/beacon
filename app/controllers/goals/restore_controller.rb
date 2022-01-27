# :nodoc:
class Goals::RestoreController < ApplicationController
  def update
    @goal = authorize Goal.deleted(goal_id: params[:id])
    @goal.parents << @goal.tree.top_level_goal
    @goal.save!
  rescue
    flash[:alert] = 'Failed to restore goal'
  ensure
    respond_to do |format|
      format.html { redirect_to @goal.tree.top_level_goal }
    end
  end
end
