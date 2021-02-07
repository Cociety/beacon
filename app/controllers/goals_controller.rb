class GoalsController < ApplicationController
  before_action :set_goal, except: %i[new create]
  before_action :set_new_child_goal, only: [:adopt]

  def new
    @goal = Goal.new
    render partial: 'popover_form', locals: { goal: @goal }
  end

  def create
    create_goal
    if @goal.save
      render partial: 'popover_form', locals: { goal: Goal.new }
    else
      render partial: 'popover_form', locals: { goal: @goal }
    end
  end

  def show; end

  def edit; end

  def update
    @goal.update! goal_params
    render json: @goal
  end

  def destroy
    @goal.destroy
    render json: @goal
  end

  def adopt
    @goal.adopt @new_child
    @top_level_goal = @goal.tree.top_level_goal
  end

  private

  def set_goal
    @goal = Goal.find(goal_id)
  end

  def goal_id
    params[:id] || params[:goal_id]
  end

  def goal_params
    params.require(:goal).permit :state, :spent, :duration, :name, :tree_id
  end

  def set_new_child_goal
    @new_child = Goal.find(params[:new_child_id])
  end

  def create_goal
    @goal = Goal.new goal_params
    @goal.parents << @goal.tree.top_level_goal unless @goal.parents.any? && @goal.tree.top_level_goal
  end
end
