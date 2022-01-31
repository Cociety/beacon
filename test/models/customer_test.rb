require "test_helper"

class CustomerTest < ActiveSupport::TestCase
  setup do
    @justin = customers(:justin)
    @tree = trees(:one)
  end

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

  test 'retrievs roles' do
    assert @justin.roles.count.positive?
  end

  test 'can add roles' do
    assert_changes -> { Role.count } do
      @justin.add_role :new_role, @tree
    end
  end

  test 'silently fails to add existing roles' do
    assert_nothing_raised do
      @justin.roles << roles(:writer_tree_one)
    end
  end

  test 'detects roles' do
    assert_not @justin.role? :reader, @tree
    assert_not @justin.role? :non_existent_role, @tree
    @justin.add_role :reader, @tree
    assert @justin.role? :reader, @tree
    assert_not @justin.role? :non_existent_role, @tree
  end

  test 'removes roles' do
    assert_not @justin.role? :reader, @tree
    @justin.add_role :reader, @tree
    assert @justin.role? :reader, @tree
    assert_changes -> { Role.count } do
      @justin.remove_role :reader, @tree
    end
    assert_not @justin.role? :reader, @tree
  end

  test 'silently fails to remove non existent roles' do
    assert_no_changes -> { Role.count } do
      @justin.remove_role :non_existent_role, @tree
    end
  end
end
