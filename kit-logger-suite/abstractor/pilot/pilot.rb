require 'selenium-webdriver'
require_relative '../../wait-until/wait-until'
require_relative 'exceptions'
require_relative 'elements/element'
require_relative 'elements/files'
require_relative 'elements/text'
require_relative 'elements/list'
require_relative 'elements/link'
require_relative 'elements/checkbox'
require_relative 'driver_navigate'
require_relative 'driver_window'
require_relative 'driver_alert'
require_relative 'module_element_finder'

class Pilot
  include ElementFinder

  def initialize(browser, arguments)
    @webdriver = Selenium::WebDriver.for browser, arguments
  end

  def active_element
    @webdriver.switch_to.active_element
  end

  # Closes the entire driver instance. You shouldn't call this until you're completely with the driver object.

  def quit
    @webdriver.quit
  end

  def capabilities
    @webdriver.capabilities
  end


  # Provides interface to the mouse

  # def mouse(identifiers)
  # Mouse.new(@webdriver, identifiers)
  # end


  # Runs any javascript passed into it.
  # You can pass in an Object Repository reference as a second parameter.
  # If you do that, the matching element will be available in arguments arr.
  # If you want to run script inside a specific frame or window, you need to
  # match that frame, or an element inside it, to ensure scripts are run within
  # that document's context.
  # example:
  # @driver.runScript("alert(arguments[0].value)"), {:id => "username"})
  # Will cause an alert dialog box, with the html element username value as its main text.

  def run_script(script_text, identifiers = {})
    dom_element = nil
    if identifiers.length != 0
      # initialize the finder and get a matching element
      finder_setup(@webdriver, identifiers)
      dom_element = prepareElement()
    end

    @webdriver.execute_script(script_text, dom_element)
  end

  def run_async_script(script_text)
    @webdriver.execute_async_script(script_text)
  end

  # Returns an alert object that handles JavaScript alerts.

  def alert
    Alert.new(@webdriver)
  end

  # Returns an element object used to interact with buttons on a page. there is no special button functionality right now.

  def button(identifiers)
    DOMElement.new(@webdriver, identifiers)
  end

  # Returns an element object used to interact with checkboxes on a page. there is no special checkbox functionality right now.

  def checkbox(identifiers)
    Checkbox.new(@webdriver, identifiers)
  end

  # Returns an Element object allowing you to use the DOM element requested.

  def element(identifiers)
    DOMElement.new(@webdriver, identifiers)
  end

  # Returns a Files object used to interact with file dialogs on a page.

  def file(identifiers)
    Files.new(@webdriver, identifiers)
  end

  # Returns a Navigate object used interact with the browsers navigation features.

  def navigate
    Navigate.new(@webdriver)
  end

  # Returns a Text element object used to interact with text fields on a page.

  def text(identifiers)
    Text.new(@webdriver, identifiers)
  end

  # Returns an element object used to interact with radio fields on a page. there is no special radio functionality right now.

  def radio(identifiers)
    DOMElement.new(@webdriver, identifiers)
  end

  # Returns an element object used to interact with links on a page. there is no special link functionality right now.

  def link(identifiers)
    Link.new(@webdriver, identifiers)
  end

  # Returns a List element object used to interact with list <Select> fields on a page.

  def list(identifiers)
    List.new(@webdriver, identifiers)
  end

  def current_url
    @webdriver.current_url
  end

  def page_source
    @webdriver.page_source
  end

  # Returns a Window object that allows you to interact with browser windows.

  def window
    Window.new(@webdriver)
  end

  def take_screenshot(screenshot_path)
    @webdriver.save_screenshot(screenshot_path)
    screenshot_path
  end

  def _im_a_cheater_webdriver
    @webdriver
  end

end
