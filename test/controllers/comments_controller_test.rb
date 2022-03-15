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
      assert_redirected_to @commentable
    end
  end

  test "can not delete someone else's comment" do
    sign_in customers(:justin)

    assert_no_changes -> { Comment.count } do
      delete comment_path comments(:hello)
      assert_redirected_to root_path
    end
  end

  test "updating redirects to commentable" do
    sign_in @comment.by
    put comment_path(@comment), params: {comment: { text: "#{@comment.text} updated" }}
    assert_redirected_to @commentable
  end
end
