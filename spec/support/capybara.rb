require 'capybara/rspec'
require 'selenium-webdriver'

Capybara.register_driver :chrome_headless do |app|

  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    'goog:loggingPrefs' => { browser: 'ALL' }
  )

  options = ::Selenium::WebDriver::Chrome::Options.new

  options.add_argument('--headless')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--window-size=1400,1400')

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options, desired_capabilities: capabilities)
end

Capybara.javascript_driver = :chrome

RSpec.configure do |config|

  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, type: :system, js: true) do 
    driven_by :selenium, using: :chrome, options: {
      browser: :remote,
      url: "http://chrome:4444/wd/hub"
    }
    Capybara.server_port = 4444
    Capybara.server_host = IPSocket.getaddress(Socket.gethostname)
  end 

=begin
  config.before(:each, type: :system, js: true) do
    driven_by :selenium, using: :chrome, options: {
      browser: :remote,
      url: "http://chrome:4444/wd/hub"
    }
    Capybara.server_host = 'app'
  end
=end
end