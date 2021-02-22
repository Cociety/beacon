require 'test_helper'

class ShareTest < ActiveSupport::TestCase
  setup do
    @justin = customers(:justin)
    @melissa = customers(:melissa)
    @role = roles(:writer_tree_one)
  end

  test 'assigns to existing customer if shared to them' do
    assert_changes -> { @melissa.roles.count } do
      Share.create! sharee: @melissa.email, role: @role, sharer: @justin
    end
  end

  test 'allows sharing to emails without an account' do
    assert_changes -> { Share.count } do
      Share.create! sharee: 'email@cociety.org', role: @role, sharer: @justin
    end
  end

  test 'notifies the sharee' do
    assert_emails 1 do
      Share.create! sharee: @melissa.email, role: @role, sharer: @justin
    end
  end
end
