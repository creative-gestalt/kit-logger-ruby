require 'selenium-webdriver'
require 'rautomation'
require_relative 'wait-until/wait-until'
require_relative 'environment/environment'
require_relative 'abstractor/selenium-abstractor'
require_relative 'scpage'

Dir["#{File.dirname(__FILE__)}/**/*.rb"].sort.each do |f|
  require f if File.basename(f) != 'testing.rb' && !File.dirname(f)[/classes/]
end

class SingleCareBase
  attr_reader :driver

  def initialize(site_url)
    configuration = {}

    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--ignore-certificate-errors')
    options.add_argument('--disable-popup-blocking')
    options.add_argument('--disable-translate')
    options.add_argument('--log-level=3')
    # options.add_argument('--headless')

    add_options_to_configuration(options, configuration)

    browser = :chrome

    create_driver(browser, configuration)

    @driver.navigate.to site_url

  end

  def create_driver(browser, configuration)
    @driver = Selenium::WebDriver::Abstractor.for browser, configuration
    puts ":browser>> #{@driver.capabilities.browser_name.capitalize} <<:"
    puts ":browser_version>> #{@driver.capabilities.version} <<:"
    puts ":chromedriver_version>> #{@driver.capabilities['chrome']['chromedriverVersion']} <<:"
  end

  def add_options_to_configuration(chrome_options, configuration)
    configuration[:options] = chrome_options
  end

  def set_screenshot_path
    env['screenshot_path'] = "#{MasterControl.data_folder_path}/results/screenshots"
    FileUtils.mkdir_p(env['screenshot_path']) if Gem.win_platform?
  end


  def open_tab
    activate_window
    rautomation_window.send_keys [:left_control, 't']
  end

  def close_tab
    rautomation_window.send_keys [:left_control, 'w']
  end

  def switch_main_tab
    rautomation_window.send_keys [:left_control, "\t"]
  end

  def use_window(window)
    @driver.window.use_window(window - 1)
    sleep 3
  end

  def close_window
    @driver.window.close
  end

  def use_next_window
    @driver.window.use_window(driver.window.count - 1)
    wait_until { @driver.window.ready? }
  end

  def use_last_window
    @driver.window.close
    @driver.window.use_window(driver.window.count - 1)
  end

  def ready?
    @driver.window.ready?
  end

  def refresh
    @driver.navigate.refresh
  end

  def start
    @driver.navigate.to env['site_url']
  end

  def url
    @driver.current_url
  end

  def browse_to(url)
    @driver.navigate.to url
  end

  def active_element
    @driver.active_element
  end

  def quit
    @driver.quit
  end

  def window_title
    @driver.window.title
  end

  def rautomation_window
    title = @driver.window.title
    RAutomation::Window.new(title: /#{Regexp.escape(title)}.*Chrom(?:e|ium)/)
  end
end
