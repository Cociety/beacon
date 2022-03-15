# Handles events from Slack. Events can be from any organization, not just Cociety.
# https://api.slack.com/apis/connections/events-api
class Slack::EventRequestController < WebhooksController
  def create
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
    params[:type] == 'event_callback' ? params[:event][:type] : params[:type]
  end

  def url_verification
    render plain: params[:challenge]
  end

  def link_shared
    channel = params[:event][:channel]
    ts = params[:event][:message_ts]
    links = params[:event][:links].map {|l| l[:url]}
    Slack::ChatUnfurlJob.perform_later channel, ts, links
    render json: {message: "ok"}
  end
end
