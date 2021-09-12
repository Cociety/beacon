# :nodoc:
class GoalsController < ApplicationController
  before_action :set_goal
  before_action :set_new_child_goal, only: [:adopt]

  def show
    @readers_and_writers = @goal.tree.readers_and_writers
  end

  def edit; end

  def update
    @goal.assign_to goal_assignee
    @goal.update! goal_params
    redirect_to goal_url @goal
  end

  def destroy
    @goal.destroy
    redirect_to @goal.tree
  end

  private

  def set_goal
    @goal = authorize Goal.find(params[:id])
  end

  def goal_params
    params.require(:goal).permit :state, :spent, :duration, :name, :tree_id, attachments: []
  end

  def goal_assignee
    customer_id = params.require(:goal).permit(:assignee_id)[:assignee_id]
    return Customer.find customer_id if customer_id
  end
end
