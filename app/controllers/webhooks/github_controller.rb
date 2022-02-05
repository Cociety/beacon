# Allows goal state changes and comments via github web hooks
# 1. Generate an api key in beacon.
# 2. Set api key as secret in github webhook.
# 3. ad ?id=<your api key id> to the request.
# Ex: https://beacon.cociety.org/webhooks/github?id=c80141e384e3b460d9c4184f6263862f916c280a
# Local testing: https://docs.github.com/en/developers/webhooks-and-events/webhooks/testing-webhooks
class Webhooks::GithubController < WebhooksController
  rescue_from StandardError, with: :bad_request

  def create
    skip_authorization
    unless push_event?
      render json: {error: 404}, status: 404
      return
    end

    unless verify_signature(request.body.read, api_key)
      render json: {status: 403}, status: 403
      Rails.logger.info "signature unknown for github delivery #{request.headers['X-GitHub-Delivery']}"
      return
    end

    Rails.logger.info "signature verified for github delivery #{request.headers['X-GitHub-Delivery']}"

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

  def bad_request(e)
    Rails.logger.info e
    render json: {error: :bad_request, status: 400}, status: 400
  end

  def api_key
    ApiKey.unscoped.find(params[:id]).key
  end

  def verify_signature(payload, key)
    signature = 'sha256=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), key, payload)
    Rack::Utils.secure_compare(signature, request.headers['HTTP_X_HUB_SIGNATURE_256'])
  end

end
