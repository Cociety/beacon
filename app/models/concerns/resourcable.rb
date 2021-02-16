module Resourcable
  extend ActiveSupport::Concern

  included do
    has_many :roles, as: :resource, dependent: :destroy
  end
end
