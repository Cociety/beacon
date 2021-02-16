module Resourcable
  extend ActiveSupport::Concern

  included do
    has_many :roles, as: :resource, dependent: :destroy

    def ruled_by?(role_name, model)
      model.role?(role_name, self)
    end

    def ruled_by_any?(role_name, model)
      ruled_by?(role_name, model)
    end
  end
end
