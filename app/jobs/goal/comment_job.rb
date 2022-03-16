class Goal::CommentJob < Slack::ApiJob
  def perform(comment_id)
    comment = Comment.find(comment_id)
    goal = comment.commentable
    commenter = comment.customer
    writers = comment.commentable.tree.writers.difference [commenter]
    readers = comment.commentable.tree.readers.difference(writers + [commenter] )
    Rails.logger.info "Slacking writers for new comment #{comment.id} #{writers.map &:id}"
    Rails.logger.info "Slacking readers for new comment #{comment.id} #{readers.map &:id}"
    send_slack_messages(writers, comment, goal, replyable: true) + send_slack_messages(readers, comment, goal)
  end

  def send_slack_messages(customers, comment, goal, replyable: false)
    messages_sent_count = 0
    customers.each do |customer|
      begin
        slack_user = @client.users_lookupByEmail email: customer.email
      rescue Faraday::Error => e
        Rails.logger.error "Failed to get slack user: #{e}"
        next
      end

      begin
        message = @client.chat_postMessage channel: slack_user["user"]["id"], blocks: blocks(comment, goal, replyable: replyable)
        messages_sent_count += 1 if message.ok?
        Rails.logger.info "Slacked #{customer.email} for comment #{comment.id}"
      rescue => e
        logger.error e
        logger.error e.backtrace
        next
      end
    end
    messages_sent_count
  end

  def blocks(comment, goal, replyable: false)
    block = [
      {
        type: :section,
        text: {
          type: :mrkdwn,
          text: ">>>#{comment.text}"
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

    if replyable
      block << { type: 'divider' }
      block <<
      {
        block_id: goal.id,
        type: 'input',
        dispatch_action: true,
        element: {
          type: 'plain_text_input',
          action_id: 'respond_to_comment',
          placeholder: {
            type: 'plain_text',
            text: 'Reply here...'
          }
        },
        label: {
          type: 'plain_text',
          text: 'Reply'
        }
      }
    end
    block
  end
end
