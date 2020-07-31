require_relative 'gems/kit-logger-suite/classes/sctools'

class KitLogger < SCTools

  def test_this
    @error = 'None'
    @kits_logged = 0
    @log_counter = 0
    @used_location_ids = []
    temp = File.readlines('data/temp/temp.txt')
    @user = temp[0].strip
    @zip_code = temp[1].strip
    @iterations = temp[2].to_i / 10
    user_info = File.readlines("Users/#{@user.to_s}/ALL/extras/credentials.txt")
    @username = user_info[0].strip
    @password = user_info[1].strip
    @group = File.read("Users/#{@user.to_s}/ALL/extras/group_number.txt")
    @member = File.readlines("Users/#{@user.to_s}/ALL/extras/member_numbers.txt")

    authorize
    log_kits
  end

  def authorize
    @start = Time.now
    @sc.do.login @username, @password
    result = @sc.location_page.retrieve_auth
    @user_id = result.first
    @api_token = result.last
  end

  def log_kits
    begin
      # uses amount of kit iterations to determine location count
      @sc.location_page.retrieve_locations(@iterations, @user_id, @api_token, @zip_code).each do |location_id|
        @used_location_ids.append(location_id)
        puts ":location>> id: #{location_id} <<:"
        # drop off 10 kits per location
        10.times do
          unless @member.length == 0 # protects against index failure
            @log_counter += 1
            response = @sc.location_page.send_drop_off_request(location_id, @member[0], @group, @api_token, @user_id)
            if response.first
              @member.delete_at(0)
              @kits_logged += 1
              sleep(0.2)
            else
              @error = response.last
              @member.delete_at(0)
              record_event
            end
          end
        end
      end
      recover_from_counter_kit_diff
      update_user_files
    rescue NoMethodError
      @error = "Location error. No Unclaimed locations."
      record_event
      return
    end
  end

  def recover_from_counter_kit_diff
    if @log_counter != @kits_logged
      @error = "Only #{@kits_logged.to_s} unclaimed locations were here."
    end
  end

  def update_user_files
    File.open('data/used/used_location_ids.txt', 'a') { |file| file.puts @used_location_ids }
    File.open('data/temp/temp.txt', 'a') { |file| file.puts @kits_logged, (Time.now - @start).round, @error }
    File.write("Users/#{@user.to_s}/ALL/extras/member_numbers.txt", @member.join(''))
  end
end
