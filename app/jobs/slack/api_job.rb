class Slack::ApiJob < ApplicationJob
  queue_as :default

  def initialize(*args, **kwargs)
    @client = Slack::Web::Client.new
    super *args, **kwargs
  end
end
