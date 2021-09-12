class UniqueGoalRelationships < ActiveRecord::Migration[6.1]
  def change
    add_index :goal_relationships, %i[parent_id child_id], unique: true
  end
end
