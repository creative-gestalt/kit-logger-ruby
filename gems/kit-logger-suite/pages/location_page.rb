module SingleCarePages
  class Location_Page < SCPage

    def retrieve_auth
      chars = 'salesRepAPICookie: "'
      code = @driver.page_source
      stripped_api = code.match(/salesRepAPICookie: "(.*)"/i)[0][chars.length..-1][0..-2]
      data = stripped_api.split('!')
      user_id = data.first
      api_token = data.last
      [user_id, api_token]
    end

    def retrieve_locations(iterations, user_id, api_token, zip_code)
      params =
          {
              Value: {
                  PostalCode: zip_code,
                  PageSize: "500"
              },
              Authentication: {
                  ApiToken: api_token,
                  UserId: user_id
              }
          }.to_json
      result = HTTPHelper.new.post('SearchPractices', params)
      # File.open('C:/Users/thebb/Desktop/text.txt', 'w') { |file| file.write(result.body) }

      filter_response(iterations, zip_code, JSON.parse(result.body))
    end

    def filter_response(iterations, zip_code, data)
      location_ids = []
      used_location_ids = File.readlines("data/used/used_location_ids.txt")
      # Gets enum through response length
      count = data['List'].length
      count.times.select do |index|
        # Filters out pending, do not pursue, and what ids we've used already
        unless used_location_ids.include? data['List'][index]['Location']['LocationId']
          if data['List'][index]['LocationStatusType'] != nil
            if data['List'][index]['LocationStatusType']['LocationStatusTypeId'] == 1
              location_ids.append(data['List'][index]['Location']['LocationId'])
            end
            # Filters out locations with reps on them if LocationStatusType is null
          elsif data['List'][index]['LocationStatusType'] == nil && data['List'][index]['SalesRepId'] == 0
            location_ids.append(data['List'][index]['Location']['LocationId'])
          end
        end
      end
      # Returns only the amount of locations we need
      if location_ids.first(iterations) == []
        remove_location(zip_code)
        # location_remover(zip_code) ### MAKE SURE THIS IS DEBUG ONLY ###
      else
        # puts "from method #{location_ids.length.to_s}"
        location_ids.first(iterations)
      end
    end

    def send_drop_off_request(location_id, member, group, api_token, user_id)
      sanitized_member = member.strip
      sanitized_group = group.strip
      params =
          {
              LocationId: location_id,
              MemberNumber: sanitized_member,
              GroupNumber: sanitized_group,
              Authentication: {
                  ApiToken: api_token,
                  UserId: user_id
              }
          }.to_json
      result = HTTPHelper.new.post('LogDropOffKit', params)
      parsed_res = JSON.parse(result.body)
      error = parsed_res['Errors']
      success = parsed_res['Success']
      if success == false
        puts error
      end
      # success = true
      [success, error]
    end

    def remove_location(zip_code)
      data = File.readlines('data/temp/temp.txt')
      zips_path = data[3].strip
      zips = File.readlines(zips_path.to_s)
      zips.delete_at(zips.index { |s| s.include? zip_code.to_s })
      File.open(zips_path, 'w') { |file| file.puts zips }
      puts "Location #{zip_code} was removed."
    end

    def location_remover(zip_code)
      arizona_master = 'data/zips/arizona_master_list.txt'
      arizona_only = 'data/zips/arizona_master_zips_only.txt'

      texas_master = 'data/zips/texas_master_list.txt'
      texas_only = 'data/zips/texas_master_zips_only.txt'

      utah_master = 'data/zips/utah_master_list.txt'
      utah_only = 'data/zips/utah_master_zips_only.txt'

      @master_path = texas_master
      @zips_only_path = texas_only

      zips_master = File.readlines(@master_path.to_s)
      zips_only = File.readlines(@zips_only_path.to_s)
      begin
        zips_master.delete_at(zips_master.index { |s| s.include? zip_code.to_s })
      rescue
        # ignore
      end
      begin
        zips_only.delete_at(zips_only.index { |s| s.include? zip_code.to_s })
      rescue
        # ignore
      end
      File.open(@master_path, 'w') { |file| file.puts zips_master }
      File.open(@zips_only_path, 'w') { |file| file.puts zips_only }
      puts "Location #{zip_code} was removed."
    end

  end
end
