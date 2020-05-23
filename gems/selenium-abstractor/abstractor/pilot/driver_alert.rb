class Alert
  def initialize(webdriver)
    @webdriver = webdriver
  end

  def cancel
    error_if_not_visible
    @webdriver.switch_to.alert.dismiss
  end

  def ok
    retries ||= 0
    sleep 0.5 # Show the alert to the tester, so they know what's going on.
    @webdriver.switch_to.alert.accept
  rescue
    retry if (retries += 1) < 3
    error_if_not_visible
  end

  def visible?
    wait = Selenium::WebDriver::Wait.new(timeout: 5)
    wait.until do
      begin
        @webdriver.switch_to.alert
      rescue Selenium::WebDriver::Error::NoAlertPresentError
        false
      end
    end
    true
  rescue Selenium::WebDriver::Error::TimeOutError
    false
  end

  def text
    error_if_not_visible
    @webdriver.switch_to.alert.text
  end

  private

  def error_if_not_visible
    unless visible?
      raise MissingAlertError, "Nothing to click on - No alert visible."
    end
  end

end
