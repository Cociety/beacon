class Goal < ApplicationRecord
  before_destroy :prepare_for_reparenting
  after_destroy :reparent_children
  belongs_to :tree
  default_scope { order(created_at: :asc) }

  # turbolinks
  after_create_commit { top_level_parent.broadcast_replace_to 'goals' }
  after_update_commit { top_level_parent.broadcast_replace_to 'goals' }
  before_destroy { @parent = top_level_parent }
  after_destroy_commit { @parent.broadcast_replace_to 'goals' }

  scope :parents, -> { left_outer_joins(:parent_relationships).merge(Relationship.where(child_id: nil)) }
  has_many :parent_relationships, foreign_key: :child_id, class_name: :Relationship, inverse_of: :child
  has_many :parents, through: :parent_relationships, inverse_of: :children, dependent: :destroy

  scope :children, -> { left_outer_joins(:parent_relationships).merge(Relationship.where.not(child_id: nil)) }
  has_many :child_relationships, foreign_key: :parent_id, class_name: :Relationship, inverse_of: :parent
  has_many :children, through: :child_relationships, inverse_of: :parents, dependent: :destroy

  enum state: { blocked: -1, assigned: 0, in_progress: 1, testing: 2, done: 3 }

  def child?
    parents.count.positive?
  end

  def top_level_parent
    return parents.first.top_level_parent if child?

    self
  end

  def prepare_for_reparenting
    @children_ids = children.pluck(:id)
    @parent_ids = parents.pluck(:id)
  end

  def reparent_children
    children = Goal.find(@children_ids)
    parents = Goal.find(@parent_ids)
    parents.each do |p|
      children.each { |c| c.add_parent p }
    end
  end

  def add_parent(new_parent)
    transaction do
      parents << new_parent
      save!
    end
  end

  def sole_parent=(new_parent)
    transaction do
      parent_relationships.destroy_all
      parents << new_parent
      save!
    end
  end
end
