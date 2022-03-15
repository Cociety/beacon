# Handles events from Slack. Events can be from any organization, not just Cociety.
# methods are mapped to slack event types
# https://api.slack.com/apis/connections/events-api
class Slack::EventRequestController < SlackController

  private

  def url_verification
    render plain: params[:challenge]
  end

  def link_shared
    Slack::ChatUnfurlJob.perform_later channel, ts, links
    render json: {message: "ok"}
  end

  private

  def channel
    params[:event][:channel]
  end

  def ts
    params[:event][:message_ts]
  end

  def links
    params[:event][:links].map {|l| l[:url]}
  end

  def event_type
    params[:type] == 'event_callback' ? params[:event][:type] : params[:type]
  end
end
