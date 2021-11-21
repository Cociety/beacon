# :nodoc:
class Goals::AdoptController < ApplicationController
  def update
    @goal = authorize Goal.find(params[:goal_id])
    @new_child = authorize Goal.find(params[:id])
    @goal.toggle_adoption @new_child
    @to = goal_path(@goal)
    render_js 'redirect'
  rescue
    flash[:alert] = 'Failed to adopt goal'
    render_js 'reload'
  end

  private

  def render_js(view)
    respond_to do |format|
      format.js { render view }
    end
  end
end
