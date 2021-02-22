module Rolable
  extend ActiveSupport::Concern

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
  end
end
