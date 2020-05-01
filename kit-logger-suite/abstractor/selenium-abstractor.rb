require 'selenium-webdriver'
require_relative 'pilot/pilot'
require_relative 'page/page'
require_relative 'page/page_name_translator'

module Selenium
  module WebDriver
    module Abstractor
      def self.for(browser, arguments)
        Pilot.new(browser, arguments)
      end
    end
  end
end
