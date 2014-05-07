require 'beaneater'

# configure beanstalkd
Beaneater.configure do |config|
  config.default_put_delay   = 0
  config.default_put_pri     = 1000
  config.default_put_ttr     = 2.minutes
  config.job_parser          = lambda { |body| Oj.load(body, :symbol_keys => true) }
end

module Q
  def self.beanstalk
    @@beanstalk ||= Beaneater::Pool.new(["#{$settings.beanstalkd_host}:#{$settings.beanstalkd_port}"])
  end

  def self.worker
    @@worker ||= beanstalk.tubes.find($settings.worker_tube)
  end
end
