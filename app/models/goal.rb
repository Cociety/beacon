class Goal < ApplicationRecord
  include Attachable, Commentable, Resourcable

  belongs_to :tree, touch: true
  default_scope { order(created_at: :asc) }
  scope :incomplete, -> { where.not(state: Goal.states[:done]) }

  before_destroy :prepare_for_reparenting
  after_destroy :reparent_children

  before_save :set_spent_based_on_done_state
  before_save :set_state_based_on_spent_and_duration

  scope :parents, -> { left_outer_joins(:parent_relationships).merge(Relationship.where(child_id: nil)) }
  has_many :parent_relationships, foreign_key: :child_id, class_name: :Relationship, inverse_of: :child
  has_many :parents, through: :parent_relationships, inverse_of: :children, dependent: :destroy

  scope :children, -> { left_outer_joins(:parent_relationships).merge(Relationship.where.not(child_id: nil)) }
  has_many :child_relationships, foreign_key: :parent_id, class_name: :Relationship, inverse_of: :parent
  has_many :children, through: :child_relationships, inverse_of: :parents, dependent: :destroy

  enum state: { blocked: -1, assigned: 0, in_progress: 1, testing: 2, done: 3 }

  DURATION_MIN = 1
  validates_numericality_of :duration, greater_than_or_equal_to: DURATION_MIN
  SPENT_MIN = 0
  validates_numericality_of :spent,
                            greater_than_or_equal_to: SPENT_MIN,
                            less_than_or_equal_to:    ->(goal) { goal.duration }

  validates :name, length: { minimum: 1, maximum: 250 }

  def remaining
    duration - spent
  end

  def percent
    (spent * 100) / duration
  end

  def set_spent_based_on_done_state
    return unless state_changed?

    self.spent = duration if state_changed_to_done?
    self.spent = 0 if state_changed_from_done?
  end

  def set_state_based_on_spent_and_duration
    if spent == duration
      self.state = Goal.states[:done] unless done?
    elsif done?
      self.state = Goal.states[:assigned]
    end
  end

  def child?
    parents.count.positive?
  end

  def prepare_for_reparenting
    @children_ids = children.pluck(:id)
    @parent_ids = parents.pluck(:id)
  end

  def reparent_children
    children = Goal.where(id: @children_ids)
    parents = Goal.where(id: @parent_ids)
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

  def adopt(new_child)
    transaction do
      new_child.parent_relationships.destroy_all
      children << new_child
      save!
    end
  end

  def assignee
    Customer.with_role(:assignee, self).first
  end

  def assignee_id
    assignee&.id
  end

  def assign_to(customer)
    return false unless customer

    transaction do
      customer.add_role(:writer, tree) unless customer.role?(:reader, tree) && !customer.role?(:writer, tree)
      roles.where(name: :assignee).destroy_all
      customer.add_role :assignee, self
    end
    true
  end

  private

  def state_changed_from_done?
    state_changed? && state_in_database == 'done'
  end

  def state_changed_to_done?
    state_changed? && done?
  end
end
