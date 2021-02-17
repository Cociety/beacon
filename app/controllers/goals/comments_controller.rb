class Goals::CommentsController < ApplicationController
  before_action :set_goal

  def create
    @comment = Comment.new comment_params
    @comment = Comment.new if @comment.save
    render turbo_stream: turbo_stream.replace(@comment, partial: 'comments/form',
                                                        locals:  { comment: @comment, on: @goal })
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
