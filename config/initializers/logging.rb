# setup of logging instruments
require 'syslogger'

class Syslogger
  def boom(boom)
    self.error("<#{boom.class.name}> '#{boom.message}'")
    backtrace = boom.backtrace
    self.error("#{backtrace}") if backtrace
  end

  # added for Sinatra env['rack.errors'] capability
  def puts(boom)
    self.error(boom.to_s) if boom
  end
end

# Will send all messages to the local0 facility, adding the process id in the message
$logger = Syslogger.new('stage_craft', Syslog::LOG_PID | Syslog::LOG_CONS, Syslog::LOG_LOCAL5)
$logger_dm = Syslogger.new('stage_craft_dm', Syslog::LOG_PID | Syslog::LOG_CONS, Syslog::LOG_LOCAL5)
$logger_worker = Syslogger.new('stage_craft_worker', Syslog::LOG_PID | Syslog::LOG_CONS, Syslog::LOG_LOCAL5)


if $settings.production?
  $logger.level = Logger::INFO
  $logger_dm.level = Logger::INFO
  $logger_worker.level = Logger::INFO
else
  $logger.level = Logger::DEBUG
  $logger_dm.level = Logger::DEBUG
  $logger_worker.level = Logger::DEBUG
end

