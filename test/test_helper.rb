ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'minitest/pride'
require 'rails/test_help'
require 'sidekiq/testing'

class ActiveSupport::TestCase
  include ActionMailer::TestHelper

  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # sign_in customers(:justin)
  include Devise::Test::IntegrationHelpers

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  # This is to fix a limitation in heroku CI pipeline
  # Rails needs superuser permissions on postgres dbs to disable foreign key constraints during test data load
  # Heroku doesn't give superuser permissions https://devcenter.heroku.com/articles/heroku-postgresql#connection-permissions
  fixtures %w[customers trees goals comments roles model_roles shares]

  # Add more helper methods to be used by all tests here...

  Sidekiq.logger.level = Logger::FATAL
  Sidekiq::Testing.fake!

  def assert_permit(customer, record, action, policy_class = nil)
    msg = "Customer #{customer.inspect} should be permitted to #{action} #{record}, but isn't permitted"
    assert permit(customer, record, action, policy_class), msg
  end

  def assert_not_permit(customer, record, action, policy_class = nil)
    msg = "Customer #{customer.inspect} should NOT be permitted to #{action} #{record}, but is permitted"
    assert_not permit(customer, record, action, policy_class), msg
  end

  def permit(customer, record, action, policy_class)
    cls = policy_class || self.class.superclass.to_s.gsub(/Test/, '').constantize
    cls.new(customer, record).public_send(action)
  end
end
