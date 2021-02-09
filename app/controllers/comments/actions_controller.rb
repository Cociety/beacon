class Comments::ActionsController < ApplicationController
  before_action :set_comment

  def show; end

  private

  def set_comment
    @comment = Comment.find params[:comment_id]
  end
end
