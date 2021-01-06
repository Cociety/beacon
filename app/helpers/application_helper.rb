module ApplicationHelper
  def sign_in_url
    cociety_url(Rails.application.config.cociety[:sign_in_path])
  end

  def sign_out_url
    cociety_url(Rails.application.config.cociety[:sign_out_path])
  end

  private

  def cociety_url(path = '/')
    cociety = Rails.application.config.cociety
    protocol = cociety[:protocol] == :http ? URI::HTTP : URI::HTTPS
    protocol.build(
      host:  cociety[:host],
      port:  cociety[:port],
      path:  path,
      query: { redirect_to: request.original_url }.to_query
    ).to_s
  end
end
