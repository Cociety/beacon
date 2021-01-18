class ReparentControllerTest < ActionDispatch::IntegrationTest
  setup do
    @parent = goals(:parent1)
    @goal = goals(:child2)
    @new_parent = goals(:child1)
  end

  test 'should move a goal to a new parent' do
    assert_equal @parent.id, @goal.parents.first.id
    put goal_reparent_url(@goal, @new_parent), as: :json
    assert_equal 1, @goal.parents.count
    assert_equal @new_parent.id, @goal.parents.first.id
  end
end
