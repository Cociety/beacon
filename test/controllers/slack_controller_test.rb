require "test_helper"

class SlackControllerTest < ActionDispatch::IntegrationTest
  test 'responds to slack url verifications' do
    post slack_event_request_url, params: {type: :url_verification, challenge: 123456, token: Rails.application.credentials.dig(:slack, :deprecated_verification_token)}, as: :json
    assert_response :ok
    assert_equal "123456", @response.body
  end

  test 'requires verifications for event requests' do
    post slack_event_request_url, params: {type: :url_verification, challenge: 123456, token: nil}, as: :json
    assert_response :unauthorized

    post slack_event_request_url, params: {type: :url_verification, challenge: 123456}, as: :json
    assert_response :unauthorized
  end
end
