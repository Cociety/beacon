require 'test_helper'

class GoalTest < ActiveSupport::TestCase
  def setup
    @parent = goals(:parent_1)
    @tree = @parent.tree
    @justin = customers(:justin)
    @melissa = customers(:melissa)
    sign_in @justin
  end

  test 'should move a goal to a new parent' do
    c1 = goals(:child_1)
    assert_equal @parent.id, c1.parents.first.id
    c2 = goals(:child_2)
    c2.adopt c1
    assert_equal 1, c1.parents.count
    assert_equal c2.id, c1.parents.first.id
  end

  test 'should save a goal' do
    assert_changes -> { Goal.count } do
      Goal.create name: 'goal', tree: @tree
    end
  end

  test 'should save child goals' do
    assert_changes -> { Goal.count } do
      c = @parent.children.create! name: 'goal', tree: @tree
      assert c.parents.first.id, @parent.id
    end
  end

  test 'should save parent goals' do
    assert_changes -> { Goal.count } do
      p = @parent.parents.create! name: 'goal', tree: @tree
      assert p.children.first.id, @parent.id
    end
  end

  test 'should get parent goals' do
    assert_changes -> { Goal.parents.count } do
      Goal.create name: 'goal', tree: @tree
    end
    assert_no_changes -> { Goal.parents.count } do
      @parent.children.create! name: 'goal', tree: @tree
    end
  end

  test 'should get child goals' do
    assert_changes -> { Goal.children.count } do
      @parent.children.create! name: 'goal', tree: @tree
    end
    assert_no_changes -> { Goal.children.count } do
      Goal.create! name: 'goal', tree: @tree
    end
  end

  test 'should delete relationships when deleting a child goal' do
    g = @parent.children.create! name: 'goal', tree: @tree

    assert_difference -> { Goal::Relationship.count }, -1 do
      g.destroy
    end
  end

  test 'should delete relationships when deleting a parent goal' do
    g = @parent.parents.create! name: 'goal', tree: @tree

    assert_difference -> { Goal::Relationship.count }, -1 do
      g.destroy
    end
  end

  test 'defaults new goals to "assigned"' do
    g = Goal.create! name: 'goal', tree: @tree
    assert_equal 'assigned', g.state
  end

  test 'minimum duration is 1' do
    assert_raise ActiveRecord::RecordInvalid do
      Goal.create! name: 'goal', tree: @tree, duration: 0
    end
    Goal.create! name: 'goal', tree: @tree, duration: 1
  end

  test 'minimum spent is 0' do
    assert_raise ActiveRecord::RecordInvalid do
      Goal.create! name: 'goal', tree: @tree, spent: -1
    end
    Goal.create! name: 'goal', tree: @tree, spent: 0
  end

  test "spent can't be greater than duration" do
    assert_raise ActiveRecord::RecordInvalid do
      Goal.create! name: 'goal', tree: @tree, spent: 2, duration: 1
    end
    Goal.create! name: 'goal', tree: @tree, spent: 1, duration: 1
  end

  test 'should set spent to duration when changing to done' do
    assert_changes -> { @parent.spent }, to: @parent.duration do
      @parent.update! state: Goal.states[:done]
    end
  end

  test 'should set spent to zero when changing from done' do
    @parent.update! state: Goal.states[:done]
    assert_changes -> { @parent.spent }, to: 0 do
      @parent.update! state: Goal.states[:assigned]
    end
  end

  test 'sets state to done when spent and duration are equal' do
    assert_changes -> { @parent.done? }, from: false, to: true do
      @parent.update! spent: 2, duration: 2
    end
  end

  test 'sets state to assigned when spent and duration are no longer equal' do
    @parent.update! spent: 2, duration: 2
    assert_changes -> { @parent.assigned? }, from: false, to: true do
      @parent.update! duration: 3
    end
  end

  test 'can add comments' do
    assert_changes -> { Comment.count } do
      @parent.comments.create text: 'this is dope', by: @justin
    end
  end

  test 'deletes comments when destroyed' do
    assert_difference -> { Comment.count }, -1 do
      @parent.destroy
    end
  end

  test 'should assign a goal to a customer' do
    assert_changes -> { @parent.assignee } do
      @parent.assign_to @justin
    end
  end

  test 'should only allow one assignee' do
    assert_difference -> { Customer.with_role(:assignee, @parent).count }, 1 do
      @parent.assign_to @justin
      @parent.assign_to @melissa
      assert_equal @melissa.id, @parent.assignee.id
    end
  end

  test 'should not grant writer role if new assignee is explict reader' do
    @melissa.remove_role :writer, @tree
    @melissa.add_role :reader, @tree
    assert_no_changes -> { @melissa.role? :writer, @tree } do
      @parent.assign_to @melissa
    end
  end

  test 'should grant writer role' do
    @melissa.remove_role :writer, @tree
    @melissa.remove_role :reader, @tree
    assert_changes -> { @melissa.role? :writer, @tree } do
      @parent.assign_to @melissa
    end
  end

  test 'should version changes' do
    assert_changes -> { @parent.versions.count } do
      @parent.update! name: "#{@parent.name}!"
    end
  end
end
