class Goal::CommentJob < Slack::ApiJob
  def perform(comment_id)
    comment = Comment.find(comment_id)
    goal = comment.commentable
    customer = comment.customer
    messages_sent_count = 0
    comment.commentable.tree.readers_and_writers.each do |customer|
      begin
        slack_user = @client.users_lookupByEmail email: customer.email
        if slack_user
          message = @client.chat_postMessage channel: slack_user["user"]["id"], blocks: blocks(comment, goal)
          messages_sent_count += 1 if message.ok?
        end
      rescue => e
        logger.error e
        next
      end
    end
    messages_sent_count
  end

  def blocks(comment, goal)
    [
      {
        type: :section,
        text: {
          type: :mrkdwn,
          text: ">*#{comment.text}*"
        }
      },
      {
        type: :context,
        elements: [
          {
            type: :mrkdwn,
            text: "New comment on Goal <#{url_for(goal)}|#{goal.name}> by"
          },
          {
            type: :image,
            image_url: avatar_url(comment.customer),
            alt_text: comment.customer.name.full
          },
          {
            type: :plain_text,
            text: comment.customer.name.first
          }
        ]
      }
    ]
  end
end
