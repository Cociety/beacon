class Goals::CommentsController < ApplicationController
  before_action :set_goal

  def create
    @comment = authorize Comment.new(comment_params), policy_class: Goal::CommentPolicy
    redirect_to @comment.commentable if @comment.save
  end

  private

  def set_goal
    @goal = Goal.find params[:goal_id]
  end

  def comment_params
    params.require(:comment)
          .permit(:text)
          .merge(by: Current.customer, commentable: @goal)
  end
end
