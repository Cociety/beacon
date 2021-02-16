class TreesController < ApplicationController
  before_action :set_tree, only: %i[show]
  before_action :set_trees, only: %i[index]
  before_action :authorize_read, only: %i[show]

  def show; end

  private

  def set_tree
    @tree = Tree.find params[:id]
  end

  def set_trees
    @trees = Current.customer
                    .roles
                    .where(name: %i[reader writer], resource_type: Tree.name)
                    .map(&:resource)
  end

  def authorize_read
    authorize! :read, @tree
  end
end
