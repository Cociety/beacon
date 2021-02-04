class CommentsController < ApplicationController
  before_action :set_commentable

  def create
    @commentable.comments.create comment_params
  end

  private

  def set_commentable
    @commentable = commentable
  end

  def commentable
    goal
  end

  def goal
    Goal.find(params[:goal_id]) if params.key? :goal_id
  end

  def comment_params
    params.require(:comment).permit(:text).merge(by: current_customer)
  end
end
