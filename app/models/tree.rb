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

  def dangling
    goals.dangling(id)
  end
end
