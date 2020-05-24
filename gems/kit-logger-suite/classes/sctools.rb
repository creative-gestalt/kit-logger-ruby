require_relative '../singlecare'
require_relative '../environment/environment'

$stdout.sync = true
#Redirect STDERR to STOUDOUT so that run.rb gets errors and stack traces, rather than just text puts to it.
$stderr = $stdout
$workflow_timing_data = []

class SCTools

  attr_writer :failed

  def setup
    @screenshot_retry_times = 0
    url = 'https://crm.singlecare.com/Account/Login'

    @sc = SingleCare.new url
    @start_time = Time.new
  end

  def teardown
    puts ":time>> Test run time: #{(Time.new - @start_time).round} seconds <<:" if @start_time
    return unless @sc

    @sc.driver.quit
  rescue StandardError => e
    puts "Note: Test 'teardown' failed. Exception: #{e} - #{e.message}"
  end

  def take_screenshots
    return unless @sc

    take_wd_screenshot
  rescue StandardError => e
    puts "Note: Failed when taking screenshots. Exception: #{e} - #{e.message}"
  end

  def take_wd_screenshot(sc = nil)
    sc ||= @sc
    return unless Gem.win_platform?

    begin
      payload = screenshot_path
      path = payload[0]
      file_name = payload[1]
      sc.driver.take_screenshot(path)
      File.open('data/temp/temp.txt', 'a') { |file| file.puts @kits_logged, (Time.new - @start_time).round, file_name }
      File.write("Users/#{@user.to_s}/ALL/extras/member_numbers.txt", @member.join(''))
      puts ":ws>> WebDriver Screenshot:{#{path}} <<:"
    rescue StandardError => e
      @screenshot_retry_times += 1
      retry if e.class == NoMethodError && @screenshot_retry_times < 3
    end
  end

  def take_screenshot(js_console: false)
    return unless Gem.win_platform?

    path = screenshot_path
    saved_successfully = take_native_screenshot path, js_console: js_console
    puts ":ns>> Native Screenshot:{#{path}} <<:" if saved_successfully
  end

  def warning(message)
    take_screenshot
    puts "\n\n:warning>> WARNING: #{message} <<:\n\n"
  end

  # Returns all object that has inherited Class.
  def self.descendants
    ObjectSpace.each_object(Class).select { |klass| klass < self }
  end

  def failed?
    @failed
  end

  def begin_clean_up
    @original_sc_session_displaced_by_clean_up = @sc
    @sc = @sc.open_second_session

    self.clean_up
  end

  def record_failure
    @failed = true
    take_screenshots
  end

  private

  def open_js_console
    @sc.driver._im_a_cheater_webdriver.find_element(tag_name: 'body').send_keys :control, :shift, 'j'
    sleep 1.5
  end

  def take_native_screenshot(path, js_console: false)
    require 'win32/screenshot'
    open_js_console if js_console
    take_screenshot_of_desktop path
  end

  def take_screenshot_of_desktop(path)
    Win32::Screenshot::Take.of(:desktop).write(path)
    true
  rescue StandardError
    false
  end

  def screenshot_path
    file_name = File.basename($PROGRAM_NAME).gsub('.rb', '')
    guid = rand(36**10).to_s(36)
    %W[C:/Users/npitts/github/kit-logger-ruby/data/screenshots/#{file_name}_#{guid}.png #{file_name}_#{guid}.png]
  end

end

at_exit do
  SCTools.descendants.each do |test|
    test = test.new
    next unless test.respond_to? :test_this

    begin
      test.setup
      test.test_this
    rescue StandardError => e
      test.record_failure
      raise e
    ensure
      if test.respond_to? :clean_up
        begin
          test.begin_clean_up
        rescue StandardError => e
          test.record_failure
          puts ":warning>>  Warning - clean up failed. #{e} #{e.backtrace.join("\n")} <<:"
        end
      end
      test.teardown
      puts ":ctime>> #{Time.now} <<:"
      puts ":result>> #{File.basename($PROGRAM_NAME, '.rb')} #{test.failed? ? 'failed' : 'passed'} <<:"
    end
  end
end
