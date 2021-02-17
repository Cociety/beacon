class TreePolicy < ApplicationPolicy
  alias tree record

  def edit?
    tree.ruled_by? :writer, customer
  end

  def create?
    new?
  end

  def show?
    tree.ruled_by_any? %i[reader writer], customer
  end
  class Scope < Scope
    def resolve
      scope.for_customer
    end
  end
end