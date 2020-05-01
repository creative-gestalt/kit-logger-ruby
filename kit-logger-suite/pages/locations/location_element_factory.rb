module SingleCarePages
  class LocationFactory
    include ElementFinder

    def self.get_locations driver
      @driver = driver
      @locations = []
      find_locations
    end

    def self.get_links
      @links = []
      find_links
    end

    def self.get_statuses
      @statuses = []
      find_statuses
    end

    def self.find_locations reattempt = 5
      locations = @driver.send :find_matching_elements, 'css', "a[title='Edit practice']"
      locations.each do |loc|
        @locations.push(loc.attribute('innerHTML'))
      end
      if @locations.empty?
        find_locations(reattempt - 1)
      else
        @locations
      end
    end

    def self.find_links reattempt = 5
      links = @driver.send :find_matching_elements, 'css', "a[title='Edit practice']"
      links.each do |loc|
        @links.push(loc.attribute('href'))
      end
      if @links.empty?
        find_links(reattempt - 1)
      else
        @links
      end
    end

    def self.find_statuses reattempt = 5
      statuses = @driver.send :find_matching_elements, 'css', "span[class^='locstatus']"
      statuses.each do |status|
        @statuses.push(status.attribute('innerHTML'))
      end
      if @statuses.empty?
        find_statuses(reattempt - 1)
      else
        @statuses
      end
    end

  end
end
