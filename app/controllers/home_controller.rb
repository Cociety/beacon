class HomeController < ApplicationController
  before_action :set_parent_goal, only: [:index]

  def set_parent_goal
    @parent_goal = Goal.parents.first
  end
end
