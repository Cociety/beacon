class Comment < ApplicationRecord
  has_paper_trail
  default_scope { order(created_at: :desc) }

  alias_attribute :by, :customer
  belongs_to :commentable, polymorphic: true, inverse_of: :comments
  belongs_to :customer

  validates :text, length: { minimum: 1 }
end
