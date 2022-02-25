class Slack::Events::RequestPolicy < ApplicationPolicy
  def event_request?
    record.verify!
  end
end
