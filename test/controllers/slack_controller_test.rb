require "test_helper"

class SlackControllerTest < ActionDispatch::IntegrationTest
  private

  def headers(body)
    timestamp = Time.now.to_i
    {
      HTTP_X_SLACK_REQUEST_TIMESTAMP: timestamp,
      HTTP_X_SLACK_SIGNATURE: slack_signature(body, timestamp)
    }
  end

  # copied-ish from slack ruby client https://github.com/slack-ruby/slack-ruby-client/blob/master/lib/slack/events/request.rb#L53
  def slack_signature(body, timestamp)
    digest = OpenSSL::Digest.new('SHA256')
    signature_basestring = ['v0', timestamp, body.to_json].join(':')
    hex_hash = OpenSSL::HMAC.hexdigest(digest, Slack::Events.config.signing_secret, signature_basestring)
    ['v0', hex_hash].join('=')
  end
end
