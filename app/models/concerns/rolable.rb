module Rolable
  extend ActiveSupport::Concern

  included do
    has_many :model_roles, foreign_key: :model_id
    has_many :roles, through: :model_roles

    def add_role(role_name, resource)
      ModelRole.transaction do
        role = Role.find_or_create_by! name: role_name, resource: resource
        ModelRole.find_or_create_by! model: self, role: role
      end
    end

    def role?(role_name, resource)
      Role.joins(:model_roles)
          .where(name: role_name, resource: resource, model_roles: { model: self })
          .count.positive?
    end

    def remove_role(role_name, resource)
      role = Role.find_by name: role_name, resource: resource
      ModelRole.destroy_by(model: self, role: role) if role
    end
  end
end
