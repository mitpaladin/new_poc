
require 'logger'

# From Sitepoint. Nicely formatted, drop-in logging. See http://j.mp/1ri0x1o+
class MainLogger
  def self.log(log_where = STDOUT)
    if @logger.nil?
      @logger = Logger.new log_where
      @logger.level = Logger::DEBUG
      @logger.datetime_format = '%Y-%m-%d %H:%M:%S '
    end
    @logger
  end
end
