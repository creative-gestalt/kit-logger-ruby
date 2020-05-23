class Navigate

  def initialize(driver_object)
    @driver = driver_object
  end
  
  # Sends the window to the specified URL.
  
  def to(url)
    @driver.navigate.to url
    self
  end
  
  # Hits the browsers back button.
  
  def back
    @driver.navigate.back
  end
  
  # Hits the browsers forward button.
  
  def forward
    @driver.navigate.forward
  end
  
  # Hits the browsers refresh button.

  def refresh
    @driver.navigate.refresh
  end

end
