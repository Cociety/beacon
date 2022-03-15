class Slack::Events::RequestPolicy < ApplicationPolicy
  def create?
    record.verify!
  end
end
