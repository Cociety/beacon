require "controllers/slack_controller_test"

class Slack::InteractiveEndpointControllerTest < SlackControllerTest
  test 'responds to link shares' do
    body = {
      payload: "{\"type\":\"block_actions\",\"user\":{\"id\":\"user_id\",\"username\":\"justin\",\"name\":\"justin\",\"team_id\":\"TEAM_ID\"},\"api_app_id\":\"A02\",\"token\":\"Shh_its_a_seekrit\",\"container\":{\"type\":\"message\",\"text\":\"The contents of the original message where the action originated\"},\"trigger_id\":\"12466734323.1395872398\",\"team\":{\"id\":\"TEAM_ID\",\"domain\":\"cocietyworkspace\"},\"enterprise\":null,\"is_enterprise_install\":false,\"state\":{\"values\":{\"y1jEf\":{\"reply_to_comment\":{\"type\":\"plain_text_input\",\"value\":\"ad\"}}}},\"response_url\":\"https://hooks.slack.com/actions/T034FJL234Z/3239472084323/5DJ55AtMDrKZGJC3V1R1LaqN\",\"actions\":[{\"type\":\"plain_text_input\",\"block_id\":\"#{Goal.first.id}\",\"action_id\":\"plain_text_input-action\",\"value\":\"ad\",\"action_ts\":\"1647308833.432095\"}]}"
    }

    post slack_interactive_endpoint_index_url, **{ params: body, headers: headers(body) }, as: :json
    assert_enqueued_with(job: Slack::ReplyToCommentJob)
    assert_response :ok
  end

end
