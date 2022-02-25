class SlackController < WebhooksController
  def event_request
    authorize token
    render plain: challenge if url_verification?
  end

  private

  def token
    Slack::VerificationToken.new params[:token]
  end

  def url_verification?
    params[:type] == 'url_verification'
  end

  def challenge
    params[:challenge]
  end
end
