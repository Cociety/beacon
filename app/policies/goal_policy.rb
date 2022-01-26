class GoalPolicy < ApplicationPolicy
  alias goal record

  def show?
    goal.tree.ruled_by_any?(%i[reader writer], customer) || goal.ruled_by?(:assignee, customer)
  end

  def update?
    goal.tree.ruled_by?(:writer, customer) || goal.ruled_by?(:assignee, customer)
  end

  def edit?
    update?
  end

  def create?
    update?
  end

  def destroy?
    update?
  end

  class Scope < Scope
    def resolve
      Tree.for_customer.joins(:goals).map(&:goals).flatten
    end
  end
end
