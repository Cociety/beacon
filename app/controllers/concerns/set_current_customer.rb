module SetCurrentCustomer
  extend ActiveSupport::Concern

  included do
    before_action do
      Current.customer = current_customer
    end
  end
end
