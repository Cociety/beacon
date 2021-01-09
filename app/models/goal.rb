class Goal < ApplicationRecord
  default_scope { order(created_at: :asc) }

  after_create_commit { replace_parent }
  after_update_commit { replace_parent }
  before_destroy { @parent = top_level_parent }
  after_destroy_commit { @parent.broadcast_replace_to 'goals' }
  
  scope :parents, -> { left_outer_joins(:parent_relationships).merge(Relationship.where child_id: nil) }
  has_many :parent_relationships, foreign_key: :child_id, class_name: :Relationship, inverse_of: :child
  has_many :parents, through: :parent_relationships, inverse_of: :children, dependent: :destroy
  
  scope :children, -> { left_outer_joins(:parent_relationships).merge(Relationship.where.not child_id: nil) }
  has_many :child_relationships, foreign_key: :parent_id, class_name: :Relationship, inverse_of: :parent
  has_many :children, through: :child_relationships, inverse_of: :parents, dependent: :destroy

  def child?
    parents.count.positive?
  end

  def replace_parent
    top_level_parent.broadcast_replace_to 'goals'
  end

  def top_level_parent
    return parents.first.top_level_parent if child?
    self
  end
end
