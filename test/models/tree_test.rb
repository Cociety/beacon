class TreeTest < ActiveSupport::TestCase
  test 'gets top_level goal' do
    assert_equal goals(:parent_1), trees(:one).top_level_goal
  end

  test 'throws error for multiple top level parents' do
    assert_raise Exception do
      trees(:multiple_top_level_parents).top_level_goal
    end
  end

  test 'throws error for no parents' do
    assert_raise Exception do
      trees(:no_parents).top_level_goal
    end
  end
end
