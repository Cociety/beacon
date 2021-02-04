class Comment < ApplicationRecord
  default_scope { order(created_at: :asc) }

  alias_attribute :by, :customer
  belongs_to :commentable, polymorphic: true
  belongs_to :customer
end
