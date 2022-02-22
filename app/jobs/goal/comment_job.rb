class Goal::CommentJob < Slack::WebhookJob
  queue_as :default

  def perform(comment_id)
    super Comment.find(comment_id).text
  end
end
