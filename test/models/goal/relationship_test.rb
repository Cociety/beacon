require "test_helper"
class Goal::RelationshipTest < ActiveSupport::TestCase
  setup do
    @parent = goals(:parent_1)
  end

  test 'should delete a relationship' do
    assert_difference -> { Goal::Relationship.count }, -1 do
      @parent.child_relationships.first.delete
    end
  end

  test 'should destroy relationships' do
    assert_difference -> { Goal::Relationship.count }, -1 do
      @parent.child_relationships.first.destroy
    end
  end
end
