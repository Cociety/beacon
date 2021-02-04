module CommentsHelper
  def commentable_comment_path(commentable)
    send "#{commentable.class.name.downcase}_comments_path"
  end
end
