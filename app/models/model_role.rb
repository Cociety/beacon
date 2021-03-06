class ModelRole < ApplicationRecord
  belongs_to :model, polymorphic: true, inverse_of: :model_roles
  belongs_to :role

  def _delete_row
    self.class._delete_record(attributes)
  end
end
