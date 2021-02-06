class Comment < ApplicationRecord
  default_scope { order(created_at: :desc) }

  after_create_commit { broadcast_append_to [commentable, :comments] }

  alias_attribute :by, :customer
  belongs_to :commentable, polymorphic: true
  belongs_to :customer
end
