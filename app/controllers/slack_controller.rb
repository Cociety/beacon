class SlackController < WebhooksController
  def event_request
    authorize slack_request
    process_event
  rescue Slack::Events::Request::MissingSigningSecret,
         Slack::Events::Request::TimestampExpired,
         Slack::Events::Request::InvalidSignature => e
    Rails.logger.error e
    raise Pundit::NotAuthorizedError, "Slack request invalid"
  end

  private

  def slack_request
    Slack::Events::Request.new request
  end

  def process_event
    self.send params[:type]
  end

  def url_verification
    render plain: params[:challenge]
  end
end
