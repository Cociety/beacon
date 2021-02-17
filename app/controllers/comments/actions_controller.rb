class Comments::ActionsController < ApplicationController
  def show
    @comment = authorize Comment.find(params[:comment_id]), policy_class: Comment::ActionPolicy
  end
end
