# :nodoc:
class Goals::RestoreController < ApplicationController
  def update
    @goal = authorize Goal.deleted(goal_id: params[:id])
    @goal.save!
    render_js 'reload'
  rescue
    flash[:alert] = 'Failed to restore goal'
    render_js 'reload'
  end

  private

  def render_js(view)
    respond_to do |format|
      format.js { render view }
      format.html { redirect_to @goal }
      format.json { redirect_to @goal }
    end
  end
end
