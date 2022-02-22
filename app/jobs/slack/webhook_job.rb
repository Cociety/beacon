require 'uri'
require 'net/http'

class Slack::WebhookJob < ApplicationJob
  queue_as :default

  # https://api.slack.com/messaging/composing/layouts
  def perform(payload, url)
    uri = URI(url)
    payload = {text: payload} if payload.is_a?(String)
    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      http.send_request 'POST', uri.request_uri, payload.to_json, {'Content-type': 'application/json'}
    end
  end
end
