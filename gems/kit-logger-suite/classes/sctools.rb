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
    # puts ":time>> Test run time: #{(Time.new - @start_time).round} seconds <<:" if @start_time
    return unless @sc

    @sc.driver.quit
  rescue StandardError => e
    puts "Note: Test 'teardown' failed. Exception: #{e} - #{e.message}"
  end

  def save_data
    return unless @sc

    save_data_to_file
  rescue StandardError => e
    puts "Note: Failed when saving error to file"
  end

  def save_data_to_file
    # File.open('data/used/used_location_ids.txt', 'a') { |file| file.puts @used_location_ids }
    # File.open('data/temp/temp.txt', 'a') { |file| file.puts @kits_logged, (Time.new - @start_time).round, @error }
    # File.write("Users/#{@user.to_s}/ALL/extras/member_numbers.txt", @member.join(''))
  end

  # Returns all object that has inherited Class.
  def self.descendants
    ObjectSpace.each_object(Class).select { |klass| klass < self }
  end

  def failed?
    @failed
  end

  def begin_clean_up
    self.clean_up
  end

  def record_event
    @failed = true
    save_data
    # take_screenshots
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
      test.record_event
      raise e
    ensure
      if test.respond_to? :clean_up
        begin
          test.begin_clean_up
        rescue StandardError => e
          test.record_event
          puts ":warning>>  Warning - clean up failed. #{e} #{e.backtrace.join("\n")} <<:"
        end
      end
      test.teardown
      puts ":result>> #{File.basename($PROGRAM_NAME, '.rb')} #{test.failed? ? 'failed' : 'passed'} <<:"
    end
  end
end
