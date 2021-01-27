class GoalsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @parent = goals(:parent1)
    @goal = goals(:child2)
    @new_parent = goals(:child1)
  end

  test 'should delete a goal' do
    children_ids = @goal.children.pluck(:id)
    parents_ids = @goal.parents.pluck(:id)
    assert_changes -> { Goal.count } do
      delete goal_url(@goal), as: :json
    end
    parents_ids.each do |p|
      children_ids.each do |c|
        assert Goal.find(p).children.include? Goal.find(c)
      end
    end
  end

  test 'should move a goal to a new parent' do
    assert_equal @parent.id, @goal.parents.first.id
    put "/goals/#{@goal.id}/sole_parent/#{@new_parent.id}", as: :json
    assert_response :ok
    assert_equal 1, @goal.parents.count
    assert_equal @new_parent.id, @goal.parents.first.id
  end

  test 'should update a goal' do
    assert_changes -> { @goal.state }, from: 'assigned', to: 'blocked' do
      put goal_url(@goal), params: { goal: { state: :blocked } }
      @goal.reload
    end
  end
end
