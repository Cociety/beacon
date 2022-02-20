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
  def largest_subtree(goal=top_level_goal, root=true)
    return nil unless goal

    subgoals = goal.children.incomplete.to_set
                            .map { |g| send(__callee__, g, false) << goal }

    if subgoals.empty? # leaf
      [goal]
    elsif !root # branch
      subgoals
    else # root
      subgoals.map(&:flatten).max_by{ |set| set.sum &:remaining }
    end
  end
end
