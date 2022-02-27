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
    if respond_to? event_type, true
      send event_type
    else
      Rails.logger.info "Unknown Slack event type \"#{event_type}\""
      render json: {message: "Unknown event type"}, status: :bad_request
    end
  end

  def event_type
    params[:type]
  end

  def url_verification
    render plain: params[:challenge]
  end
end
