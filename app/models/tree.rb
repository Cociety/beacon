class Tree < ApplicationRecord
  default_scope { order(updated_at: :desc) }
  has_many :goals, -> { includes :child_relationships }
end
