module Commentable
  extend ActiveSupport::Concern

  included do
    has_many :comments, as: :commentable, inverse_of: :commentable, dependent: :destroy
    accepts_nested_attributes_for :comments
  end
end
