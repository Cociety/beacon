# Handles interactions from Slack. Events can be from any organization, not just Cociety.
# https://api.slack.com/interactivity
class Slack::InteractiveEndpointController < SlackController
  before_action :set_payload

  def block_actions
    unless slack_user_id.present? && goal_id.present? && comment_text.present?
      Rails.logger.error "Missing required arguments"
      render json: {message: "ok"}
      return
    end
    Slack::ReplyToCommentJob.perform_later slack_user_id, goal_id, comment_text
    render json: {message: "ok"}
  end

  private

  def slack_user_id
    @payload['user']['id']
  end

  def goal_id
    action['block_id']
  end

  def comment_text
    action['value']
  end

  def action
    @payload['actions'].first
  end

  def event_type
    @payload['type']
  end

  def set_payload
    @payload = JSON.parse params[:payload]
  end

end
