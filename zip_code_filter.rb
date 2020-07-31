require_relative 'gems/kit-logger-suite/classes/sctools'

class ZipCodeFilter < SCTools

  def test_this
    arizona = 'data/zips/arizona_master_zips_only.txt'
    texas = 'data/zips/texas_master_zips_only.txt'
    utah = 'data/zips/utah_master_zips_only.txt'
    @zip_codes = File.readlines(texas)
    user_info = File.readlines("Users/Nick/ALL/extras/credentials.txt")
    @username = user_info[0].strip
    @password = user_info[1].strip
    @location_count = 0

    authorize
    request_practices
  end

  def authorize
    @sc.do.login @username, @password
    result = @sc.location_page.retrieve_auth
    @user_id = result.first
    @api_token = result.last
  end

  def request_practices
    @zip_codes.each do |zip|
      results = @sc.location_page.retrieve_locations(10000, @user_id, @api_token, zip.strip)
      if results != nil && 0
        results.each do |location_id|
          @location_count += 1
        end
        puts "#{@location_count} locations found"
        @location_count = 0
      end
    end
  end
end
