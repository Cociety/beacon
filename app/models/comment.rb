class Comment < ApplicationRecord
  alias_attribute :by, :customer
  belongs_to :commentable, polymorphic: true
  belongs_to :customer
end
