class Tree < ApplicationRecord
  default_scope { order(updated_at: :desc) }
  has_many :goals, -> { joins(:children).eager_load(:children) }

  def top_level_goal
    possible_parents = goals.index_by(&:id)
    goals.each { |g| g.children.each { |c| possible_parents.delete c.id } }

    raise 'Found multiple top level parents' if possible_parents.size > 1

    raise 'Possible infinite loop detected' if possible_parents.empty?

    _, goal = possible_parents.first
    goal.tree = self
    goal
  end
end
