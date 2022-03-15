require 'test_helper'

VCR.configure do |config|
  config.ignore_request do |request|
    host = URI(request.uri).host
    ['chromedriver.storage.googleapis.com', '127.0.0.1'].include? host
  end
end

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :chrome, screen_size: [1400, 1400]
end
