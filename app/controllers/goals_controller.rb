class GoalsController < ApplicationController
  before_action :set_goal

  def destroy
    tree = @goal.tree
    @goal.destroy
    @top_level_goal = tree.top_level_goal
  end

  private

  def set_goal
    @goal = Goal.find(params[:id])
  end
end
