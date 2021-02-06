class CommentsController < ApplicationController
  before_action :set_commentable

  def create
    @comment = Comment.new comment_params
    @comment = Comment.new(commentable: @commentable) if @comment.save
    render turbo_stream: turbo_stream.replace(@comment, partial: 'comments/form', locals: { comment: @comment })
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
    params.require(:comment).permit(:text).merge(by: current_customer, commentable: @commentable)
  end
end
