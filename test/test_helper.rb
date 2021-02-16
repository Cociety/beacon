ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'minitest/pride'
class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # sign_in customers(:justin)
  include Devise::Test::IntegrationHelpers

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  # This is to fix a limitation in heroku CI pipeline
  # Rails needs superuser permissions on postgres dbs to disable foreign key constraints during test data load
  # Heroku doesn't give superuser permissions https://devcenter.heroku.com/articles/heroku-postgresql#connection-permissions
  fixtures %w[customers trees goals comments roles]

  # Add more helper methods to be used by all tests here...
end
