require "application_system_test_case"

class GoalsTest < ApplicationSystemTestCase
  setup do
    @justin = customers(:justin)
    @parent = goals(:parent_1)
  end

  test "clicks a child goal" do
    sign_in @justin
    visit goal_url(@parent)

    assert_selector "h1", text: "parent_1"
  
    click_on "child_1"

    assert_selector "h1", text: "child_1"
  end
end
