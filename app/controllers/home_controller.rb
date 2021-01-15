class HomeController < ApplicationController
  before_action :set_goals, only: [:index]

  def set_goals
    @goals = Tree.first.goals
    @goal = @goals.first
  end
end
