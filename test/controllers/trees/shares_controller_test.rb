require 'test_helper'

class Tree::SharesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tree = trees(:one)
    @justin = customers(:justin)
    sign_in @justin
  end

  test 'shares a tree' do
    assert_changes -> { Share.count } do
      post tree_share_path(@tree), params: { share: { sharee: 'someone@cociety.org' } }
      assert_response :ok
    end
  end
end
