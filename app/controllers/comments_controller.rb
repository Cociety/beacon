class CommentsController < ApplicationController
  before_action :set_commentable
  before_action :set_comment, except: %i[create]

  def create
    @comment = Comment.new create_comment_params
    @comment = Comment.new(commentable: @commentable) if @comment.save
    render turbo_stream: turbo_stream.replace(@comment, partial: 'comments/form', locals: { comment: @comment })
  end

  def edit; end

  def update
    @comment.update! update_comment_params
  end

  private

  def set_commentable
    @commentable = commentable
  end

  def set_comment
    @comment = Comment.find params[:id]
  end

  def commentable
    goal
  end

  def goal
    Goal.find(params[:goal_id]) if params.key? :goal_id
  end

  def comment_params
    params.require(:comment).permit(:text)
  end

  def create_comment_params
    comment_params.merge(by: Current.customer, commentable: @commentable)
  end

  def update_comment_params
    comment_params
  end
end
