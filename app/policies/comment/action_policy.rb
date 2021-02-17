class Comment::ActionPolicy < ApplicationPolicy
  alias comment record

  def show?
    comment.customer = customer
  end
end
