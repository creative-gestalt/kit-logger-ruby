# puts ":kit_logger>> #{ENV['computername']} <<:"
# puts ":time>> #{Time.now} <<:"
require 'fileutils'
require 'json'

class KitLoggerSuite

  def self.base_path
    File.expand_path "#{__dir__}/kit-logger-suite/"
  end

end
