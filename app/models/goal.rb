class Goal < ApplicationRecord
  belongs_to :tree, touch: true
  default_scope { order(created_at: :asc) }

  before_destroy :prepare_for_reparenting
  after_destroy :reparent_children

  before_save :check_for_done

  scope :parents, -> { left_outer_joins(:parent_relationships).merge(Relationship.where(child_id: nil)) }
  has_many :parent_relationships, foreign_key: :child_id, class_name: :Relationship, inverse_of: :child
  has_many :parents, through: :parent_relationships, inverse_of: :children, dependent: :destroy

  scope :children, -> { left_outer_joins(:parent_relationships).merge(Relationship.where.not(child_id: nil)) }
  has_many :child_relationships, foreign_key: :parent_id, class_name: :Relationship, inverse_of: :parent
  has_many :children, through: :child_relationships, inverse_of: :parents, dependent: :destroy

  enum state: { blocked: -1, assigned: 0, in_progress: 1, testing: 2, done: 3 }

  validates_numericality_of :duration, greater_than_or_equal_to: 1
  validates_numericality_of :remaining, greater_than_or_equal_to: 1, less_than_or_equal_to: ->(goal) { goal.duration }

  def spent
    duration - remaining
  end

  def percent
    (spent * 100) / duration
  end

  def check_for_done
    self.remaining = 0 if state_changed? && state == 'done'
  end

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
