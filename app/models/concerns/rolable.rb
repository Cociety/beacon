# allows a model to have roles (from the homegrown Roles class) attached and removed from it
module Rolable
  extend ActiveSupport::Concern

  included do
    has_many :roles do
      # dedupes before saving to prevent unique exceptions
      def <<(new_item)
        super(Array(new_item) - proxy_association.owner.roles)
      end
    end

    def add_role(role_name, resource)
      roles.find_or_create_by!(name: role_name, resource: resource, customer: self)
    end

    def role?(role_name, resource)
      roles.exists? name: role_name, resource: resource, customer: self
    end

    def remove_role(role_name, resource)
      roles.destroy_by name: role_name, resource: resource, customer: self
    end

    def self.with_role(roles, resource)
      Role.where(name: roles, resource: resource)
          .includes(:customer)
          .map &:customer
    end
  end
end
