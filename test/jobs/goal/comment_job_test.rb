require 'test_helper'
class Goal::CommentJobTest < ActiveJob::TestCase
  def test_send_comments_to_slack
    VCR.use_cassette("slack_comments") do
      messages_sent_count = Goal::CommentJob.perform_now comments(:hello).id
      assert_equal 1, messages_sent_count
    end
  end
end
