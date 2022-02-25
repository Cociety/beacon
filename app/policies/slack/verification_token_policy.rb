class Slack::VerificationTokenPolicy < ApplicationPolicy
  def event_request?
    record.token == verification_token
  end

  private

  def verification_token
    Rails.application.credentials.dig(:slack, :deprecated_verification_token)
  end
end
