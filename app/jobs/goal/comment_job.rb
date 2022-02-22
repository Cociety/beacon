class Goal::CommentJob < Slack::WebhookJob
  queue_as :default

  def perform(comment_id)
    comment = Comment.find(comment_id)
    goal = comment.commentable
    customer = comment.customer
    slack_webhook_url = comment.commentable.tree.slack_webhook_url

    payload = {
      blocks: [
        {
          type: :section,
          text: {
            type: :mrkdwn,
            text: "> *#{comment.text}*"
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
              image_url: avatar_url(customer),
              alt_text: customer.name.full
            },
            {
              type: :plain_text,
              text: customer.name.full
            }
          ]
        }
      ]
    }
    super payload, slack_webhook_url
  end
end
