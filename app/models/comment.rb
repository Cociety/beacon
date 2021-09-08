class Comment < ApplicationRecord
  default_scope { order(created_at: :desc) }

  # broadcasts_to ->(comment) { [comment.commentable, :comments] }

  alias_attribute :by, :customer
  belongs_to :commentable, polymorphic: true, inverse_of: :comments
  belongs_to :customer

  validates :text, length: { minimum: 1 }
end
