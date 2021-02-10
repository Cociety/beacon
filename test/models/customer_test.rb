require "test_helper"
class CustomerTest < ActiveSupport::TestCase
  test 'should be readonly' do
    assert_raise ActiveRecord::ReadOnlyRecord do
      Customer.new(password: :password, email: 'beacon@cociety.org').save!
    end

    c = customers(:justin)
    assert_raise ActiveRecord::ReadOnlyRecord do
      c.update first_name: c.first_name
    end

    assert_raise ActiveRecord::ReadOnlyRecord do
      c.save
    end
  end
end
