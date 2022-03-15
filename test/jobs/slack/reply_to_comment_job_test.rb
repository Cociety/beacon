require 'test_helper'
class Slack::ReplyToCommentJobTest < ActiveJob::TestCase
  def test_replies_to_comments
    VCR.use_cassette("slack_comment_replies") do
      assert_changes -> { Comment.count } do
        Slack::ReplyToCommentJob.perform_now 'user_1', Goal.first.id, 'reply to comment'
      end
    end
  end

  def test_obeys_writer_role
    VCR.use_cassette("slack_comment_replies_no_write") do
      assert_raise Pundit::NotAuthorizedError do
        Slack::ReplyToCommentJob.perform_now 'user_1', Goal.first.id, 'reply to comment'
      end
    end
  end
end
