class HomeController < ApplicationController
  before_action :set_tree, only: [:index]

  def set_tree
    @tree = Tree.first
  end
end
