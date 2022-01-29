require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Beacon
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    ENV['PORT'] ||= '3001'

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.action_view.field_error_proc = proc { |html_tag, instance|
      error_tags = html_tag.starts_with?('<input ') ? instance.full_error_messages.map { |m| "<div class=\"field_error\">#{m}</div>" }.join : ''
      "<div class=\"field_with_errors\">#{html_tag}#{error_tags}</div>".html_safe
    }

    config.active_storage.replace_on_assign_to_many = false

    config.active_job.queue_adapter = :sidekiq

    # nil will use the "default" queue
    # some of these options will not work with your Rails version
    # add/remove as necessary
    config.action_mailer.deliver_later_queue_name = nil # defaults to "mailers"
    config.active_storage.queues.analysis   = nil       # defaults to "active_storage_analysis"
    config.active_storage.queues.purge      = nil       # defaults to "active_storage_purge"
    config.active_storage.queues.mirror     = nil       # defaults to "active_storage_mirror"
  end
end
