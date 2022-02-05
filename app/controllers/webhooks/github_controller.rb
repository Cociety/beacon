class Webhooks::GithubController < WebhooksController
  rescue_from StandardError, with: :bad_request

  def create
    skip_authorization
    unless push_event?
      render json: {error: 404}, status: 404
      return
    end

    commit_messages
    render json: {status: 200}
  end

  private
  def push_event?
    github_event_type.downcase == 'push'
  end

  def github_event_type
    request.headers['X-GitHub-Event']
  end

  def payload
    raise StandardError.new 'payload must be a JSON string' unless params[:payload]
    JSON.parse params[:payload]
  end

  def commit_messages
    payload['commits'].map { |commit| commit['message'] }
  end

  def bad_request
    render json: {error: :bad_request, status: 400}
  end

end
