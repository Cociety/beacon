class GoalsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @goal = goals(:child2)
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
end
