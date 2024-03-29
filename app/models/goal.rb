# rubocop:disable Metrics/ClassLength
class Goal < ApplicationRecord
  include Attachable, Commentable, Resourcable
  has_paper_trail

  belongs_to :tree, touch: true
  default_scope { order(created_at: :asc) }
  scope :incomplete, -> { where.not(state: Goal.states[:done]) }

  before_save :set_spent_based_on_done_state
  before_save :set_state_based_on_spent_and_duration

  # prevent deleting if this is a top level goal
  # allows top level goal deletion if being deleted by associated tree
  before_destroy prepend: true, unless: :destroyed_by_association do
    errors.add(:top_level, "Can't delete top level goal") if top_level?
    throw(:abort) if errors.present?
  end
  before_destroy :prepare_for_reparenting
  after_destroy :reparent_children

  scope :parents, -> { left_outer_joins(:parent_relationships).merge(Relationship.where(child_id: nil)) }
  has_many :parent_relationships, foreign_key: :child_id, class_name: :Relationship, inverse_of: :child
  has_many :parents, through: :parent_relationships, inverse_of: :children, dependent: :destroy

  scope :children, -> { left_outer_joins(:parent_relationships).merge(Relationship.where.not(child_id: nil)) }
  has_many :child_relationships, foreign_key: :parent_id, class_name: :Relationship, inverse_of: :parent
  has_many :children, through: :child_relationships, inverse_of: :parents, dependent: :destroy

  scope :similar_name, ->(name) { where('name % :name', name: name) }
  scope :similar_name_excluding_id, ->(name, id) { similar_name(name).where.not(id: id) }
  scope :deleted, ->(tree_id: nil, goal_id: nil) {
     # find deleted goals
    deleted_goals = PaperTrail::Version.where(event: 'destroy', item_type: self.class.to_s.deconstantize)

    # optionally in the same tree
    deleted_goals = tree_id ? deleted_goals.where("object->>'tree_id' = ?", tree_id) : deleted_goals

    # optionally specific goal id
    deleted_goals = goal_id ? deleted_goals.where(item_id: goal_id) : deleted_goals

    deleted_goals.select('DISTINCT ON ("versions"."item_id") item_id, *')      # don't show duplicate goal deletions
                 .joins("LEFT JOIN #{table_name} ON item_id=#{table_name}.id") # find existing goals
                 .where(goals: { id: nil })                                    # that haven't been restored
                 .order(item_id: :desc, created_at: :desc)                     # show the latest deletion if deleted multiple times
                 .map &:reify
  }
  scope :top_level, -> { where top_level: true }
  scope :dangling, ->(tree_id = nil) {
    goals = Goal.includes(:parents, :children)
        .where(
          parents_goals: {id: nil},
          children_goals: {id: nil},
          top_level: false
        )

    goals = tree_id ? goals.where(tree_id: tree_id) : goals
  }

  # these must be in increments of 1 with no gaps
  # because of the range input field used here app/views/goals/_state.html.erb
  enum state: { blocked: -1, assigned: 0, in_progress: 1, testing: 2, done: 3 }

  DURATION_MIN = 1
  validates :duration, numericality: { greater_than_or_equal_to: DURATION_MIN }
  SPENT_MIN = 0
  validates :spent,
            numericality: { greater_than_or_equal_to: SPENT_MIN,
                            less_than_or_equal_to:    ->(goal) { goal.duration } }

  validates :name, length: { minimum: 1, maximum: 250 }

  def deleted_from_same_tree
    Goal.deleted tree_id: tree_id
  end

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

  # Adopts a child goal or unadopts if goal is already a child
  def toggle_adoption(child_goal)
    adopt child_goal
  rescue ActiveRecord::RecordNotUnique
    child_goal.reload
    unadopt child_goal
  end

  # make this goal the parent of child_goal
  def adopt(child_goal)
    raise "Can't adopt self" if id == child_goal.id

    raise "Can't adopt parent" if parents.pluck(:id).include? child_goal.id

    children << child_goal
  end

  # Unadopt a child goal as its parent. Prevents dangling goals and won't unadopt if child has no other parents
  def unadopt(child_goal)
    child_goal.parent_relationships.where(parent_id: id).destroy_all if child_goal.parent_relationships.many?
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

  # Find goals similar to this one
  def similar
    # todo authorize goals
    Goal.similar_name_excluding_id(name, id)
  end

  private

  def state_changed_from_done?
    state_changed? && state_in_database == 'done'
  end

  def state_changed_to_done?
    state_changed? && done?
  end
end
