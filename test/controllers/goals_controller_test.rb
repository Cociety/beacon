require 'test_helper'
class GoalsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @parent = goals(:parent_1)
    @goal = goals(:child_2)
    @new_parent = goals(:child_1)
    @justin = customers(:justin)
    sign_in @justin
  end

  test 'should delete a goal and reparent its children' do
    children_ids = @goal.children.pluck(:id)
    parents_ids = @goal.parents.pluck(:id)
    assert_changes -> { Goal.count } do
      delete goal_url(@goal)
    end
    parents_ids.each do |p|
      children_ids.each do |c|
        assert Goal.find(p).children.include? Goal.find(c)
      end
    end
  end

  test 'should move a goal to a new parent' do
    assert_equal @parent.id, @goal.parents.first.id
    put goal_adopt_url(@new_parent, @goal), as: :json
    assert_redirected_to @new_parent
    assert_array_equal [@parent.id, @new_parent.id], @goal.parents.pluck(:id)
  end

  test 'should update a goal' do
    assert_changes -> { @goal.state }, from: 'assigned', to: 'blocked' do
      put goal_url(@goal), params: { goal: { state: :blocked } }
      @goal.reload
    end
  end
end
