require_relative 'gems/kit-logger-suite/classes/sctools'

class KitLogger < SCTools

  def test_this
    @kits_logged = 0
    temp = File.readlines('data/temp/temp.txt')
    @user = temp[0].strip
    @zip_code = temp[1].strip
    @iterations = temp[2].to_i / 10
    user_info = File.readlines("Users/#{@user.to_s}/ALL/extras/credentials.txt")
    @username = user_info[0].strip
    @password = user_info[1].strip
    @group = File.read("Users/#{@user.to_s}/ALL/extras/group_number.txt")
    @member = File.readlines("Users/#{@user.to_s}/ALL/extras/member_numbers.txt")

    log_in
    log_kits
    update_user_files
  end

  def log_in
    @start = Time.now
    @sc.do.login @username, @password
    @sc.location_page.zip_code = @zip_code
    @sc.location_page.search
  end

  def log_kits
    @sc.location_page.collect_unclaimed(@iterations, @zip_code).each do |link|
      @sc.location_page.open_location link
      puts ":location>> link: #{link} <<:"
      10.times do
        @sc.kit_page.drop_off_kits
        @sc.kit_page.set_group @group
        @sc.kit_page.set_member @member[0]
        @sc.kit_page.close # close -> debug :: log_kit -> live
        @member.delete_at(0)
        @kits_logged += 1
      end
      @sc.kit_page.close_tab
    end
  end

  def update_user_files
    File.open('data/temp/temp.txt', 'a') { |file| file.puts @kits_logged, (Time.now - @start).round }
    File.write("Users/#{@user.to_s}/ALL/extras/member_numbers.txt", @member.join(''))
  end

end
