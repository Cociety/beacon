class Role < ApplicationRecord
  belongs_to :resource, polymorphic: true, inverse_of: :roles
  belongs_to :customer
  has_many :shares
end
