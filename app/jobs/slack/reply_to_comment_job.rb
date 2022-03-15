class Slack::ReplyToCommentJob < Slack::ApiJob
  include Pundit
  def perform(slack_user_id, goal_id, comment_text)
    goal = Goal.find goal_id
    @customer = customer(slack_user_id)
    new_comment = goal.comments.new(text: comment_text, customer: @customer)
    authorize new_comment, policy_class: Goal::CommentPolicy
    new_comment.save!
  end

  private

  def customer(slack_user_id)
    slack_user = @client.users_info user: slack_user_id
    Customer.find_by email: slack_user[:user][:profile][:email]
  end

  # tricking pundit into thinking it's in a controller
  # https://github.com/varvet/pundit/blob/main/lib/pundit/authorization.rb#L62
  def action_name
    :create
  end

  # tell pundit the user
  # https://github.com/varvet/pundit/blob/main/lib/pundit/authorization.rb#L158
  def pundit_user
    @customer
  end
end
