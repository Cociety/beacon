require 'test_helper'
class Goal::CommentJobTest < ActiveJob::TestCase
  def test_send_comments_to_slack
    VCR.use_cassette("slack", match_requests_on: [:body]) do
      response = Goal::CommentJob.perform_now comments(:hello).id
      assert response.code == '200'
    end
  end
end
