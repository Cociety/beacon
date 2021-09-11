require 'test_helper'

class Tree::GoalsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tree = trees(:one)
    @justin = customers(:justin)
    sign_in @justin
  end

  test 'should assign new goals to the logged in customer' do
    assert_changes -> { Goal.count } do
      post tree_goals_path(@tree), params: { goal: { state: :assigned, spent: 0, duration: 1, name: 'a' } }
      assert_equal @justin.id, Goal.last.assignee.id
    end
  end
end
