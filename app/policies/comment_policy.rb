class CommentPolicy < ApplicationPolicy
  alias comment record

  def update?
    comment.customer.id == customer.id
  end

  def edit?
    update?
  end

  def destroy?
    update?
  end
end
