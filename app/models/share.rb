class Share < ApplicationRecord
  after_create_commit :notify
  after_create_commit :assign_role_to_customer_if_exist

  alias_attribute :sharer, :customer

  belongs_to :role
  delegate :resource, to: :role
  belongs_to :customer

  validates :sharee, presence: true, email: true

  def notify
    ShareMailer.with(share: self).tree_shared.deliver_later
  end

  private

  def assign_role_to_customer_if_exist
    customer = Customer.find_by(email: sharee)
    return unless customer

    customer.add_role role.name, role.resource
  end
end
