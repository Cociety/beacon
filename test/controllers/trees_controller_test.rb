require 'test_helper'
class TreesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @justin = customers(:justin)
    sign_in @justin
  end

  test 'should create a tree and a top level goal' do
    assert_changes -> { Tree.count } do
      assert_changes -> { Goal.count } do
        post trees_url
      end
    end
  end
end
