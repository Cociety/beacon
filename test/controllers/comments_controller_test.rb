require 'test_helper'

class CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @commentable = goals(:parent_1)
    @comment = comments(:hello)
  end

  test 'commenter can delete' do
    sign_in @comment.by

    assert_changes -> { Comment.count } do
      delete comment_path @comment
      assert_response :ok
    end
  end

  # test "can not delete someone else's comment" do
  #   sign_in customers(:melissa)

  #   assert_no_changes -> { Comment.count } do
  #     delete comment_path comments(:hello)
  #     assert_response :not_found
  #   end
  # end
end
