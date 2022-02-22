class ApplicationJob < ActiveJob::Base
  include Rails.application.routes.url_helpers
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError

  private
    def default_url_options
      Rails.application.config.action_mailer.default_url_options
    end
end
