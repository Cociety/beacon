module CommentsHelper
  def commentable_comment_path(commentable)
    send "#{commentable.class.name.downcase}_comments_path", commentable.id
  end

  # Replace any anchor tag or url string with an anchor tag
  def urls_to_hrefs(string)
    string.gsub(/<a.*>(.*)<\/a>/, '\1')
          .gsub(/(https?:\/\/\S+)|(\S+\.(com?|org|net|gov|edu|de))/, '<a target="_blank" href="\0">\0</a>')
  end
end
