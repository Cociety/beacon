# :nodoc:
class Tree < ApplicationRecord
  include Resourcable

  default_scope { order(updated_at: :desc) }
  has_many :goals, -> { includes(:children, :parents) }, dependent: :destroy, autosave: true

  def top_level_goal
    goal = goals.top_level.first

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

  def readers_and_writers
    Customer.with_role %i[reader writer], self
  end

  # TODO convert this. use the goal's scope
  # https://apidock.com/rails/ActiveRecord/SpawnMethods/merge
  def dangling
    goals.dangling(id)
  end

  # finds the deepest path in the tree and returns an array of goals in order from head to leaf goal.
  # This is used to recommend which goals can be assigned to someone else (parallelized)
  # Ex: would return [parent, child 1, child 1.1] since it has a depth of 2 and other children have depth 1
  # parent
  # |_ child 1
  #   |_ child 1.1
  # |_ child 2
  # |_ child 3
  def deepest_path(goal=top_level_goal, top_level=true)
    return nil unless goal

    deepest = goal.children.incomplete
                           .map { |g| send(__callee__, g, false).prepend(goal) }
                           .max_by { |gs| gs.longest_continuous_range_by(&:assignee).size }
    return [goal] unless deepest

    if top_level
      deepest.longest_continuous_range_by &:assignee
    else
      deepest
    end
  end
end
