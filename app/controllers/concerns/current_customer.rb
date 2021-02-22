module CurrentCustomer
  extend ActiveSupport::Concern

  included do
    def set_current_customer
      Current.customer = current_customer
    end
  end
end
