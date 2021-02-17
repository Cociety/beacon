class ApplicationPolicy
  attr_reader :customer, :record

  def initialize(customer, record)
    @customer = customer
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  class Scope
    attr_reader :customer, :scope

    def initialize(customer, scope)
      @customer = customer
      @scope = scope
    end

    def resolve
      scope.all
    end
  end
end
