# :nodoc:
class GoalsController < ApplicationController
  before_action :set_goal
  before_action :set_new_child_goal, only: [:adopt]

  def show
    @tree_readers = @goal.tree.readers
    @tree_writers = @goal.tree.writers
    @tree_readers_and_writers = (@tree_readers + @tree_writers).union
    @show_completed_goals = show_completed_goals?
    @goals_to_parallelize = @goal.tree.largest_subtree @goal
    @goals_to_parallelize = [] if @goals_to_parallelize&.sum(&:remaining) < 3
  end

  def edit; end

  def update
    assignee = goal_assignee

    customer_can_be_assigned?(assignee)

    @goal.assign_to goal_assignee
    @goal.update! goal_params_casted
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
    params.require(:goal).permit(:state, :spent, :duration, :name, :tree_id, attachments: [])
  end

  def goal_params_casted
    raw_params = goal_params
    if Goal.states.values.map(&:to_s).include? raw_params[:state]
      raw_params[:state] = raw_params[:state].to_i
    end
    raw_params
  end

  def goal_assignee
    customer_id = params.require(:goal).permit(:assignee_id)[:assignee_id]
    return Customer.find customer_id if customer_id
  end

  def show_completed_goals?
    ActiveRecord::Type::Boolean.new.deserialize params[:show_completed_goals]
  end

  def customer_can_be_assigned?(customer)
    @pundit_customer = customer
    authorize @goal.tree
    @pundit_customer = nil
  end
end
