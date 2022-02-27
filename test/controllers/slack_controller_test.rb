require "test_helper"

class SlackControllerTest < ActionDispatch::IntegrationTest
  test 'responds to link shares' do
    body = {
      type: :event_callback,
      event: {
        type: :link_shared,
        channel: 'channel',
        event_ts: '123456621.1855',
        links: [
          {
            domain: 'cociety.org',
            url: 'https://beacon.cociety.org/'
          }
        ]
      }
    }
    post slack_event_request_url, **{ params: body, headers: headers(body) }, as: :json
    assert_enqueued_with(job: Slack::ChatUnfurlJob)
    assert_response :ok
  end

  test 'responds to slack url verifications' do
    body = {type: :url_verification, challenge: 123456}
    post slack_event_request_url, **{ params: body, headers: headers(body) }, as: :json
    assert_response :ok
    assert_equal "123456", @response.body
  end

  test 'requires verifications for event requests' do
    body = {type: :url_verification, challenge: 123456}
    post slack_event_request_url, params: body, as: :json
    assert_response :unauthorized
  end

  test 'rejects unknown event types' do
    body = {type: :unknown_random}
    post slack_event_request_url, **{ params: body, headers: headers(body) }, as: :json
    assert_response :bad_request
    assert_equal "{\"message\":\"Unknown event type\"}", @response.body
  end

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
