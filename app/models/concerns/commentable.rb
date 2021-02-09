module Commentable
  extend ActiveSupport::Concern

  included do
    has_many :comments, as: :commentable, inverse_of: :commentable
  end
end
