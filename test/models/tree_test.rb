require 'test_helper'
class TreeTest < ActiveSupport::TestCase
  setup do
    @one = trees(:one)
  end

  test 'gets top_level goal' do
    assert_equal goals(:parent_1), @one.top_level_goal
  end

  test 'returns nil for no parents' do
    assert_nil trees(:no_parents).top_level_goal
  end

  test 'loads if only one goal exists' do
    assert_equal goals(:only_one), trees(:with_one_goal).top_level_goal
  end

  test 'destroying a tree destroys all dependent entities' do
    assert_changes -> { Tree.count } do
      assert_changes -> { Goal.count } do
        assert_changes -> { Comment.count } do
          @one.destroy
        end
      end
    end
  end

  test 'finds the deepest path' do
    assert_equal [goals(:parent_1), goals(:child_2), goals('subchild_2.1')], @one.deepest_path
  end
end
