class GoalPolicy < ApplicationPolicy
  alias goal record

  def show?
    goal.tree.ruled_by_any? %i[reader writer], customer
  end

  def update?
    goal.tree.ruled_by? :writer, customer
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
end
