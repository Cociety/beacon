module Resourcable
  extend ActiveSupport::Concern

  included do
    has_many :roles, as: :resource, dependent: :destroy
    has_many :model_roles, through: :roles

    scope :for_customer, ->(customer = Current.customer) {
      joins(:model_roles)
        .where(roles: { name: %i[reader writer] }, model_roles: { model: customer })
    }

    def ruled_by?(role_name, model)
      model&.role?(role_name, self)
    end

    def ruled_by_any?(role_name, model)
      ruled_by?(role_name, model)
    end
  end
end
