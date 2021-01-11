class GoalTest < ActiveSupport::TestCase
  def setup
    @parent = goals(:parent1)
  end

  test 'should move a goal to a new parent' do
    c1 = goals(:child1)
    assert_equal @parent.id, c1.parents.first.id
    c2 = goals(:child2)
    c1.make_child_of(c2)
    assert_equal 1, c1.parents.count
    assert_equal c2.id, c1.parents.first.id
  end

  test 'should save a goal' do
    assert_changes -> { Goal.count } do
      Goal.new.save
    end
  end

  test 'should save child goals' do
    assert_changes -> { Goal.count } do
      c = @parent.children.new
      c.save!
      assert c.parents.first.id, @parent.id
    end
  end

  test 'should save parent goals' do
    assert_changes -> { Goal.count } do
      p = @parent.parents.new
      p.save!
      assert p.children.first.id, @parent.id
    end
  end

  test 'should get parent goals' do
    assert_changes -> { Goal.parents.count } do
      Goal.new.save
    end
    assert_no_changes -> { Goal.parents.count } do
      @parent.children.new.save!
    end
  end

  test 'should get child goals' do
    assert_changes -> { Goal.children.count } do
      @parent.children.new.save!
    end
    assert_no_changes -> { Goal.children.count } do
      Goal.new.save
    end
  end

  test 'should delete relationships when deleting a child goal' do
    g = @parent.children.new
    g.save

    assert_difference -> { Goal::Relationship.count }, -1 do
      g.destroy
    end
  end

  test 'should delete relationships when deleting a parent goal' do
    g = @parent.parents.new
    g.save

    assert_difference -> { Goal::Relationship.count }, -1 do
      g.destroy
    end
  end
end
