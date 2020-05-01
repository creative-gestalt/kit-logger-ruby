require_relative 'abstractor/page/page'

class SCPage < Page

  def initialize(driver, sc = nil)
    @sc = sc
    super driver
  end

end
