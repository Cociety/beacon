require "test_helper"

class ApiKeyControllerTest < ActionDispatch::IntegrationTest
  setup do
    @justin = customers :justin
    @justin_key_1 = api_keys :justin_key_1
    @melissa_key_1 = api_keys :melissa_key_1
    sign_in @justin
  end

  test "lists a customer's api key ids but not the keys" do
    get api_keys_url
    assert_select 'td', { count: 1, text: 'justin_key_id_1' }
    assert_select 'td', { count: 0, text: 'justin_key_1' }
  end

  test "allows a customer to delete their api key" do
    assert_changes -> { ApiKey.unscoped.count } do
      delete api_key_url(@justin_key_1)
    end
  end

  test "refuses to delete another customers api key" do
    assert_no_changes -> { ApiKey.unscoped.count } do
      delete api_key_url(@melissa_key_1)
    end
  end

  test "shows key after creation" do
    post api_keys_url
    follow_redirect!
    new_api_key = ApiKey.unscoped.order(:created_at).last
    assert_select '.api_key-key', { count: 1, text: new_api_key.key }

    # shouldn't show again
    get api_keys_url
    assert_select '.api_key-key', { count: 0 }
  end
end
