class Comment < ApplicationRecord
  has_paper_trail
  default_scope { order(created_at: :desc) }

  alias_attribute :by, :customer
  belongs_to :commentable, polymorphic: true, inverse_of: :comments
  belongs_to :customer
  after_create_commit :send_slack_message

  validates :text, length: { minimum: 1 }

  def send_slack_message
    Goal::CommentJob.perform_later id
  end
end
