require 'test_helper'
class TreesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @justin = customers(:justin)
    @melissa = customers(:melissa)
    @tree = trees(:one)
    @goal = goals(:parent_1)
    @share_writer_tree_one = shares(:writer_tree_one)
    sign_in @justin
  end

  test 'should load trees page' do
    get trees_url
    assert_response :success
  end

  test 'tree should redirect to top level goal' do
    get tree_url(@tree)
    assert_redirected_to goal_url(@goal)
  end

  test 'should create a tree and a top level goal' do
    assert_changes -> { Tree.count } do
      assert_changes -> { Goal.count } do
        post trees_url
      end
    end
  end

  test 'should load a shared tree' do
    sign_out @justin
    sign_in @melissa
    assert_changes -> { @melissa.role? :writer, @tree } do
      get tree_url(@tree), params: { share: @share_writer_tree_one.id }
    end
  end
end
