require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  def setup
    @hello = comments(:hello)
    @justin = customers(:justin)
    sign_in @justin
  end

  test 'should version changes' do
    assert_changes -> { @hello.versions.count } do
      @hello.update! text: "#{@hello.text}!"
    end
  end
end
