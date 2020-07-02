module SingleCarePages
  class Location_Page < SCPage

    text 'zip_code', css('input#zip')
    button 'search', id('btnSearch')
    button 'next_button', css("li[id='practiceResults_next'] > a[aria-controls='practiceResults']")
    button 'next_disabled', css("li[class='paginate_button next disabled']")
    button 'page_one', css("li[class*='paginate_button'] > a[data-dt-idx='1']")

    element 'location_name', css("a[title='Edit practice']")
    element 'next_button', css("li[id='practiceResults_next'] > a[aria-controls='practiceResults']")
    element 'loader_icon', css("img[class='loader-icon']")
    element 'empty_table', css("td[class='dataTables_empty']")

    def open_location(link)
      link 'location', css("a[href='#{link}']")
      until location?
        next_button
        wait_until { !loader_icon_element.visible? }
      end
      wait_until { !loader_icon_element.visible? }
      wait_until { location_element.visible? }
      location_element.send_keys %i[control enter]
      @driver.window.use_window 1
    end

    def collect_unclaimed(iterations, zip_code)
      links = []
      base_url = 'https://crm.singlecare.com'
      while links.length <= iterations
        results = scrape_location_data
        # this checks if the zip code has zero locations, if so, we remove it
        remove_location(zip_code) if results.nil?
        unclaimed_indexes = filter_for_index(results[2], 'Unclaimed')
        unclaimed_indexes.each { |num| links.push(results[1][num][base_url.length..-1]) }

        puts "#{links.length} unclaimed links found."
        break if links.length >= iterations || next_disabled_element.visible?

        next_button
        wait_until { !loader_icon_element.visible? }
      end
      target_links = links.slice(0, iterations)
      # this checks if there is no unclaimed, if so, we remove it
      remove_location(zip_code) if target_links == []
      navigate_page_one
      target_links
    end

    def filter_for_index(list, value)
      list.size.times.select { |i| list[i] == value }
    end

    def navigate_page_one
      wait_until { page_one_element.visible? }
      page_one
      wait_until { !loader_icon_element.visible? }
    end

    def remove_location(zip_code)
      data = File.readlines('data/temp/temp.txt')
      zips_path = data[3].strip
      zips = File.readlines(zips_path.to_s)
      zips.delete_at(zips.index { |s| s.include? zip_code })
      File.open(zips_path, 'w') { |file| file.puts zips }
      puts "Location #{zip_code} was removed."
      wait_until { !next_disabled_element.visible? }
    end

    def scrape_location_data
      wait_until { !loader_icon_element.visible? }
      return if empty_table_element.visible?

      locations = LocationFactory.get_locations(@driver)
      links = LocationFactory.get_links
      statuses = LocationFactory.get_statuses
      [locations, links, statuses]
    end

  end
end
