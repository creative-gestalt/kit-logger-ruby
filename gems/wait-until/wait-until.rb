require "timeout"
require "sourcify"
#
#The default timeout should be set in the environment variables
#

module Wait
  @@default = 10

  def default
    @@default
  end

  def default=(time_out)
    @@default = time_out
  end

  def wait_until(time_out = @@default, &block)
    #timeout supports floats and integers.
    time_out = time_out.to_f

    Timeout::timeout(time_out){

      until block.call do
        #puts "waiting for condition to be true."
      end
    }
    return true
  rescue Timeout::Error
    begin
      raise Timeout::Error, "'#{block.to_raw_source(:strip_enclosure => true)}' didn't return true within #{time_out.to_s} seconds."
    rescue NoMethodError
      raise Timeout::Error, "Block didn't return true within #{time_out.to_s} seconds."
    end
  end
end

include Wait
