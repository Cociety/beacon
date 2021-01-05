module ApplicationHelper
  def sign_in_url
    cociety = Rails.application.config.cociety
    protocol = cociety[:protocol] == :http ? URI::HTTP : URI::HTTPS
    protocol.build(
      host:  cociety[:host],
      port:  cociety[:port],
      path:  cociety[:sign_in_path],
      query: { redirect_to: request.original_url }.to_query
    ).to_s
  end
end
