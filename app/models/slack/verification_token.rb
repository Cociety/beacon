class Slack::VerificationToken
  attr_reader :token

  def initialize(token)
    @token = token
  end
end