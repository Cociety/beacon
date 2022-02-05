class ApiKeyPolicy < ApplicationPolicy
  alias api_key record

  def index?
    destroy?
  end

  def destroy?
    api_key.customer.id == Current.customer.id
  end

  class Scope < Scope
    def resolve
      Current.customer.api_keys
    end
  end
end
