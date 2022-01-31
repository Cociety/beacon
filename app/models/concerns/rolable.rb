# allows a model to have roles (from the homegrown Roles class) attached and removed from it
module Rolable
  extend ActiveSupport::Concern

  # rubocop:disable Metrics/BlockLength
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
      ids = resource.roles
                    .where(name: roles )
                    .pluck(:customer_id)

      # Customers are in another db so we can't do a join to get these
      where id: ids
    end
  end
  # rubocop:enable Metrics/BlockLength
end
