class CommentsController < ApplicationController
  before_action :set_comment

  def show; end

  def edit; end

  def destroy
    @comment.destroy
    render json: @comment
  end

  def update
    @comment.update! comment_params
  end

  private

  def set_comment
    @comment = authorize Comment.find params[:id]
  end

  def comment_params
    params.require(:comment).permit(:text)
  end
end
