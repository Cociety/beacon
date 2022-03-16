require 'test_helper'
class GoalsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @parent = goals(:parent_1)
    @goal = goals(:child_2)
    @new_parent = goals(:child_1)
    @justin = customers(:justin)
    @melissa = customers(:melissa)
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
    assert_changes -> { @goal.reload.state }, from: 'assigned', to: 'blocked' do
      put goal_url(@goal), params: { goal: { state: :blocked } }
    end
  end

  test 'should render goal comments with links' do
    get goal_url(@goal)
    assert_select 'p', **{text: 'cociety.org'} do
      assert_select 'a[href="cociety.org"]'
    end

    assert_select 'p', **{text: 'example.com'} do
      assert_select 'a[href="example.com"]'
    end

    assert_select 'p', **{text: 'https://example.net'} do
      assert_select 'a[href="https://example.net"]'
    end

    assert_select 'p', **{text: 'https://example.edu'} do
      assert_select 'a[href="https://example.edu"]'
    end
  end

  test 'should hide completed goals' do
    get goal_url(@parent)

    assert_select ".tree a:match('href', ?)", /\/goals\/.+/, count: 6
  end

  test 'should show completed goals if enabled' do
    get goal_url(@parent), **{params: {show_completed_goals: 1}}

    assert_select '.tree' do
      assert_select "a:match('href', ?)", /\/goals\/.+/, count: 7
    end
  end

  test 'should show goals to parallelize' do
    get goal_url(@parent)

    assert_select 'span', {count: 3, text: 'Parallelizable'}
  end

  test 'should show only writers to be assigned' do
    get goal_url(@parent)

    assert_select '#goal_assignee_id option', {count: 2} do |options|
      options.each do |option|
        value = option.attr 'value'
        next if option.text == 'Please select' && value.blank?

        assert Customer.find(value).role? :writer, @parent.tree
      end
    end
  end

  test 'should only allow writers to be assigned' do
    assert_no_changes -> { @parent.reload.assignee } do
      put goal_url(@parent), params: { goal: { assignee_id: @melissa.id } }
      assert_redirected_to root_url
    end
  end
end
