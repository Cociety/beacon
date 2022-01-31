# read what roles (from the homegrown Roles class) are attached
# and which models (usually Customers) have access to those roles
module Resourcable
  extend ActiveSupport::Concern

  included do
    has_many :roles, as: :resource, dependent: :destroy

    scope :for_customer, lambda { |customer = Current.customer|
        joins(:roles)
        .where(roles: { name: %i[reader writer], customer: customer })
        .distinct
    }

    def ruled_by?(role_name, model)
      model&.role?(role_name, self)
    end

    def ruled_by_any?(role_name, model)
      ruled_by?(role_name, model)
    end
  end
end
