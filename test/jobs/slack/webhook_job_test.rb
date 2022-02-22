require 'test_helper'
class Slack::WebhookJobTest < ActiveJob::TestCase
  def test_send_text_to_slack
    VCR.use_cassette("slack", match_requests_on: [:body]) do
      response = Slack::WebhookJob.perform_now 'test', trees(:one).slack_webhook_url
      assert response.code == '200'
    end
  end
end
