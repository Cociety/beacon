class Goal::Relationship < ApplicationRecord
  belongs_to :parent, class_name: :Goal, inverse_of: :child_relationships
  belongs_to :child, class_name: :Goal, inverse_of: :parent_relationships
  has_one :tree, through: :parent, touch: true

  def _delete_row
    self.class._delete_record({ parent_id: parent_id, child_id: child_id })
  end
end
