class Goal::CommentPolicy < ApplicationPolicy
  alias comment record

  def show?
    tree.ruled_by_any? %i[reader writer], customer
  end

  def create?
    tree.ruled_by? :writer, customer
  end

  private

  def tree
    comment.commentable.tree
  end
end
