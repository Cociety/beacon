class Tree < ApplicationRecord
  include Resourcable

  default_scope { order(updated_at: :desc) }
  has_many :goals, -> { includes(:children, :parents) }, dependent: :destroy

  after_create_commit { broadcast_prepend_to 'tree_preview', partial: '/trees/preview' }
  after_update_commit { reload and broadcast_replace_to 'tree' }
  after_destroy_commit { broadcast_replace_to 'tree' }

  def top_level_goal
    goal = top_level_goal_without_tree_ref

    return goal if goal.nil?

    # to help views avoid hitting the db for the tree
    goal.tree = self
    goal
  end

  def spent
    goals.map(&:spent).sum
  end

  def duration
    goals.map(&:duration).sum
  end

  def remaining
    goals.map(&:remaining).sum
  end

  def percent
    if duration.zero?
      0
    else
      (spent * 100) / duration
    end
  end

  private

  def top_level_goal_without_tree_ref
    # edge case with zero or one goal since it won't have parents or children
    return goals.first if goals.size <= 1

    # goals without parents and with children
    tlgs = goals.select { |g| g.parents.empty? and g.children.any? }

    raise 'Found multiple top level parents' if tlgs.size > 1

    raise 'Possible infinite loop detected' if tlgs.empty?

    # only one at this point
    tlgs.first
  end
end
