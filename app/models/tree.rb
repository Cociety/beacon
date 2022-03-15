# :nodoc:
class Tree < ApplicationRecord
  include Resourcable

  default_scope { order(updated_at: :desc) }
  has_many :goals, dependent: :destroy, autosave: true

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

  def writers
    Customer.with_role %i[writer], self
  end

  def readers
    Customer.with_role %i[reader], self
  end

  # TODO convert this. use the goal's scope
  # https://apidock.com/rails/ActiveRecord/SpawnMethods/merge
  def dangling
    goals.dangling(id)
  end

  # finds the largest subtree weighted by goal duration in the tree and returns a set of goals in the subtree.
  # This is used to recommend which goals can be assigned to someone else (parallelized)
  # Ex: would return [parent, child 1, child 1.1] since it has a weight of 3 and other children have weight of 2
  # parent
  # |_ child 1
  #   |_ child 1.1
  # |_ child 2
  # |_ child 3
  def largest_subtree(root=top_level_goal)
    subtree_roots = root&.children&.incomplete&.to_set
    goals_to_search = root&.children&.incomplete&.to_a

    largest_subtree = []
    largest_subtree_size = 0
    current_assignee = nil
    current_subtree = []
    current_subtree_size = 0

    while !goals_to_search.empty?
      g = goals_to_search.pop
      g.children.incomplete.each { |child| goals_to_search << child }

      end_of_branch = (current_assignee != g.assignee) || subtree_roots.include?(g)
      current_subtree << g unless end_of_branch

      if end_of_branch
        current_subtree_size = current_subtree.sum(&:remaining)
        larger = current_subtree_size > largest_subtree_size
        if larger
          largest_subtree = current_subtree
          largest_subtree_size = current_subtree_size
        end
        current_assignee = g.assignee
        current_subtree = Set[g]
      end
    end

    current_subtree_size = current_subtree.sum(&:remaining)
    larger = current_subtree_size > largest_subtree_size
    if larger
      largest_subtree = current_subtree
      largest_subtree_size = current_subtree_size
    end

    largest_subtree
  end
end
