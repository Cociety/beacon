class TreePolicy < ApplicationPolicy
  alias tree record

  def edit?
    tree.ruled_by? :writer, customer
  end

  def new?
    edit?
  end

  def create?
    customer.present?
  end

  def show?
    tree.ruled_by_any? %i[reader writer], customer
  end

  def share?
    customer.present? && edit?
  end

  class Scope < Scope
    def resolve
      scope.for_customer
    end
  end
end
