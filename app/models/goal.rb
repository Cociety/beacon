class Goal < ApplicationRecord
  default_scope { order(created_at: :asc) }

  scope :children, -> { left_outer_joins(:parent_relationships).merge(Relationship.where.not child_id: nil) }
  scope :parents, -> { left_outer_joins(:parent_relationships).merge(Relationship.where child_id: nil) }

  has_many :parent_relationships, foreign_key: :child_id, class_name: :Relationship, inverse_of: :child
  has_many :parents, through: :parent_relationships, inverse_of: :children, dependent: :destroy

  has_many :child_relationships, foreign_key: :parent_id, class_name: :Relationship, inverse_of: :parent
  has_many :children, through: :child_relationships, inverse_of: :parents, dependent: :destroy
end
