# Abstract Slack controller that authorizes requests
# methods are mapped to slack event types
class SlackController < WebhooksController
  before_action :authorize_slack_request

  def create
    if event_type.present? && respond_to?(event_type, true)
      send event_type
    else
      Rails.logger.info "Unknown Slack event type \"#{event_type}\""
      render json: {message: "Unknown event type"}, status: :bad_request
    end
  end

  private

  def authorize_slack_request
    authorize slack_request
  rescue Slack::Events::Request::MissingSigningSecret,
         Slack::Events::Request::TimestampExpired,
         Slack::Events::Request::InvalidSignature => e
    Rails.logger.error e
    raise Pundit::NotAuthorizedError, "Slack request invalid"
  end

  def slack_request
    Slack::Events::Request.new request
  end
end
