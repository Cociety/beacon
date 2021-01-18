class HomeController < ApplicationController
  before_action :set_top_level_goal, only: [:index]

  def set_top_level_goal
    @top_level_goal = Tree.first.top_level_goal
  end
end
