class ReparentController < ApplicationController
  before_action :set_goal, only: [:update]

  def update
    @goal.make_child_of(@new_parent)
    @goal = @goal.tree.goals.first
    render template: 'reparent/update.json'
  end

  def set_goal
    @goal = Goal.find(params[:goal_id])
    @new_parent = Goal.find(params[:id])
  end
end
