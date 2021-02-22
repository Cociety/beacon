class Role < ApplicationRecord
  belongs_to :resource, polymorphic: true, inverse_of: :roles
  has_many :model_roles
  has_many :shares
end
