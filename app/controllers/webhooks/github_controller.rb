# Allows goal state changes and comments via github web hooks
# 1. Generate an api key in beacon.
# 2. Set api key as secret in github webhook.
# 3. ad ?id=<your api key id> to the request.
# 4. after commiting and before pushing run `git notes add -m "<goal_id>"`
# 5. The goal will be marked done if:
#       1. It is a push event from GitHub
#       2. An api key with id is found
#       3. The request signature is verified
#       4. The goal in the notes exist
#       5. The owner of the api key is authorized to modify the goal
# Ex: https://beacon.cociety.org/webhooks/github?id=c80141e384e3b460d9c4184f6263862f916c280a
# Local testing: https://docs.github.com/en/developers/webhooks-and-events/webhooks/testing-webhooks
class Webhooks::GithubController < WebhooksController
  def create
    raise StandardError.new "Can't handle event #{github_event_type}" unless push_event?

    unless verify_signature(request.body.read, api_key.key)
      render json: {status: 403}, status: 403
      Rails.logger.info "signature unknown for github delivery #{request.headers['X-GitHub-Delivery']}"
      return
    end

    Rails.logger.info "signature verified for github delivery #{request.headers['X-GitHub-Delivery']}"
    Current.customer = api_key.customer

    commits = commits_with_goals_to_mark_done
    skip_authorization unless commits.any?
    commits.each do |commit|
      commit['goal'].update! state: Goal.states[:done]
      commit['goal'].comments.new(text: "[bot] Done! #{commit['url']}", customer: Current.customer).save!
    end
    render json: {status: 200}
  rescue => e
    Rails.logger.info e
    skip_authorization
    render json: {error: :bad_request, status: 400}, status: 400
  end

  private
  def push_event?
    github_event_type.downcase == 'push'
  end

  def github_event_type
    request.headers['X-GitHub-Event']
  end

  def api_key
    ApiKey.unscoped.find(params[:id])
  end

  def verify_signature(payload, key)
    signature = 'sha256=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), key, payload)
    Rack::Utils.secure_compare(signature, request.headers['HTTP_X_HUB_SIGNATURE_256'])
  end

  def commits_with_goals_to_mark_done
    payload['commits'].each { |commit| commit['goal_id'] = /goal\:\s*(?<goal_id>[\w-]*)/.match(commit['message'])&.[](:goal_id) }
                      .select { |commit| commit['goal_id'].present? }
                      .each { |commit| commit['goal'] = Goal.find_by(id: commit['goal_id'])  }
                      .select { |commit| commit['goal'].present? }
                      .each { |commit| authorize commit['goal'] }
  end

  def goal_ids
    commit_messages.filter_map { |m| /goal\:\s*(?<goal_id>[\w-]*)/.match(m)&.[](:goal_id) }
  end

  def commit_messages
    payload['commits'].map { |commit| commit['message'] }
  end

  def payload
    raise StandardError.new 'payload must be a JSON string' unless params[:payload]
    JSON.parse params[:payload]
  end
end
