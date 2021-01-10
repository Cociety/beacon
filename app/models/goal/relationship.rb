class Goal::Relationship < ApplicationRecord
  belongs_to :parent, foreign_key: :parent_id, class_name: :Goal, inverse_of: :child_relationships
  belongs_to :child, foreign_key: :child_id, class_name: :Goal, inverse_of: :parent_relationships

  def _delete_row
    self.class._delete_record({ parent_id: parent_id, child_id: child_id })
  end
end
