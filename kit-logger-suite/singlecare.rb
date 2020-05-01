require_relative 'singlecare_base'
require_relative 'abstractor/page/page_name_translator'
require_relative 'do'
require_relative 'pages/location_page'

Dir["#{File.dirname(__FILE__)}/pages/*.rb"].sort.each do |f|
  require_relative f
end

class SingleCare < SingleCareBase
  include PageNameTranslator

  def initialize url
    super
    PageNameTranslator.append_methods_to self, SingleCarePages
  end

  def do
    DoStuff.new @driver, self
  end

  def quit
    @driver.quit
  end
end
