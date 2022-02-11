require 'application_system_test_case'

class SharesTest < ApplicationSystemTestCase
  setup do
    @tree = trees(:one)
    @justin = customers(:justin)
    @melissa = customers(:melissa)
  end

  test 'accessing a shared tree grants access' do
    assert_not_permit @melissa, @tree, :show?, TreePolicy
    sign_in @melissa
    share = shares(:writer_tree_one)
    visit tree_url(share.resource, params: { share: share.id })
    assert_permit @melissa, @tree, :show?, TreePolicy
  end
end
