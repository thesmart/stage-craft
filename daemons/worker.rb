require_relative '../config/initializers/stage_craft_app'
require_relative '../config/initializers/vendor'

class Worker

  def initialize
  end

  # Called when a send_email_job is processed
  def send_email_job(job)
    meta = {
      :from => job.body[:from],
      :to => job.body[:to],
      :subject => job.body[:subject],
      :html => job.body[:html]
    }
    $mailgun.send(meta)
  end

end

# use the right logger
$logger = $logger_worker;

# handle exit
at_exit do
  Q.beanstalk.close
  puts 'good bye.'
end

# handle jobs
$worker = Worker.new
Q.beanstalk.jobs.register($settings.worker_tube) do |job|
  begin
    job_type = job.body[:type] ? job.body[:type].to_sym : nil
    unless job_type and $worker.respond_to?(job_type)
      raise RuntimeError.new "job type '#{job.body[:type]}' not supported"
    end
    $worker.public_send(job_type, job)
  rescue StandardError => boom
    $logger.error("#{boom.inspect}\nBacktrace:\n#{boom.backtrace.slice(0,10).join("\n")}")
  end
end

Q.beanstalk.jobs.process!