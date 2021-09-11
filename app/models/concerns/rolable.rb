# allows a model to have roles (from the homegrown Roles class) attached and removed from it
module Rolable
  extend ActiveSupport::Concern

  # rubocop:disable Metrics/BlockLength
  included do
    has_many :model_roles, foreign_key: :model_id, inverse_of: :model
    has_many :roles, through: :model_roles do
      # dedupes before saving to prevent unique exceptions
      def <<(new_item)
        super(Array(new_item) - proxy_association.owner.roles)
      end
    end

    def add_role(role_name, resource)
      role = Role.find_or_create_by! name: role_name, resource: resource
      roles << role
    end

    def role?(role_name, resource)
      Role.joins(:model_roles)
          .exists?(name: role_name, resource: resource, model_roles: { model: self })
    end

    def any_role?(role_name, resource)
      role? role_name, resource
    end

    def remove_role(role_name, resource)
      role = Role.find_by name: role_name, resource: resource
      ModelRole.destroy_by(model: self, role: role) if role
    end

    # maybe do something like `has_many :models, through: :model_roles, source_type: :Customer, disable_joins: true`
    # after rails 7 upgrade https://github.com/rails/rails/pull/41937
    def self.with_role(roles, resource)
      ids = resource.model_roles
                    .where(model_type: model_name.name)
                    .joins(:role)
                    .where(role: { name: roles })
                    .pluck(:model_id)

      # Customers are in another db so we can't do a join to get these
      where id: ids
    end
  end
  # rubocop:enable Metrics/BlockLength
end
