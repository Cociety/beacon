require 'uri'
require 'net/http'

class Slack::WebhookJob < ApplicationJob
  queue_as :default

  def perform(text)
    uri = URI('https://hooks.slack.com/services/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')
    payload = {text: text}.to_json
    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      http.send_request 'POST', uri.request_uri, payload, {'Content-type': 'application/json'}
    end
  end
end
