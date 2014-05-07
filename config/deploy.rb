set :application, 'StageCraft'
set :user, 'deploy'
role :app, %w{deploy@production_ssh}

# locations
set :tmp_dir, '/home/deploy/tmp'
set :deploy_to, '/home/deploy/www/stage-craft'

# get branch from git root
set :repo_url, 'git@github.com:thesmart/stage-craft.git'
#ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }
set :scm, :git
set :scm_verbose, true
set :git_shallow_clone, 1
set :keep_releases, 5

root = File.absolute_path("#{__dir__}/../")
rbenv_path = '/home/dev/.rbenv/shims/'
rack_env = "production"
unicorn_config = {
  :config_file_path => "#{shared_path}/unicorn.rb",
  :worker_processes => 4,
  :pid_file => "#{shared_path}/unicorn.pid",
  :host => '127.0.0.1',
  :port => '1337',
  :stderr_path => "#{shared_path}/unicorn_error.log",
  :stdout_path => "#{shared_path}/unicorn_out.log"
}
nginx_config = {
  :root_host => 'example.com',
  :web_host => 'www.example.com',
  :root_url => 'http://www.example.com',
  :config_file_path => "#{shared_path}/nginx.conf",
  :pid_file => "#{shared_path}/nginx.pid",
  :access_log => "#{shared_path}/nginx_access.log",
  :error_log => "#{shared_path}/nginx_error.log",
}
beanstalkd_config = {
  :pid_file => "#{shared_path}/beanstalkd.pid",
  :host => '127.0.0.1',
  :port => '11300',
  :stdout_path => "#{shared_path}/beanstalkd_out.log",
  :stderr_path => "#{shared_path}/beanstalkd_error.log",
}
subsidy_config = {
  :host => '127.0.0.1',
  :port => '63063',
}

##############################
#
#   DEPLOYMENT TASKS
#
##############################

after 'deploy:updated', 'app:configure'

namespace :deploy do
  desc "restart application"
  task :restart do
    #invoke 'app:restart'
  end
end

##############################
#
#   APPLICATION TASKS
#
##############################

namespace :app do

  desc "configure application"
  task :configure do
    on roles(:app) do
      cmds = []
      cmds << "mkdir -p #{shared_path}"
      cmds << "mkdir -p #{shared_path}/vendor_bundle"
      cmds << "mkdir -p #{release_path}/vendor"
      execute cmds.join('; ')

      cmds = []
      cmds << "cd #{release_path}/services/subsidy_calculator"
      cmds << "npm install"
      execute cmds.join('; ')

      cmds = []
      cmds << "cd #{release_path}"
      cmds << "ln -s #{shared_path}/vendor_bundle #{release_path}/vendor/bundle"
      cmds << "#{rbenv_path}bundle install --without darwin --path #{shared_path}/vendor_bundle"
      execute cmds.join('; ')
    end
    invoke 'unicorn:configure'
    invoke 'nginx:configure'
    invoke 'foreman:configure'
  end

  desc "0-downtime restart"
  task :restart do
    invoke 'unicorn:restart'
  end

  desc "Start all the servers necessary to start the application"
  task :start do
  end

  task :stop do
  end

end

##############################
#
#   FOREMAN
#
##############################

namespace :foreman do
  desc "load production Profile and export foreman to upstart"
  task :configure do
    on roles(:app) do
      # Production Procfile
      procfile_erb = ERB.new(File.read("#{root}/config/Procfile.erb"))
      procfile = procfile_erb.result(binding)
      stream = StringIO.new(procfile)
      upload!(stream, "#{release_path}/Procfile")

      # environment variables
      upload!("#{root}/config/deploy/production.env", "#{release_path}/.env")

      # export to Ubuntu upstart
      execute "cd #{release_path}; sudo #{rbenv_path}bundle exec foreman export -a StageCraft -u #{fetch(:user)} -l #{shared_path} upstart /etc/init"
    end
  end
end

##############################
#
#   UNICORN SEVER
#
##############################

namespace :unicorn do

  desc "configures unicorn"
  task :configure do
    on roles(:app) do
      execute "touch #{unicorn_config[:pid_file]}"
      conf_erb = ERB.new(File.read("#{root}/config/unicorn.rb.conf.erb"))
      conf = conf_erb.result(binding)
      stream = StringIO.new(conf)
      upload!(stream, unicorn_config[:config_file_path])
    end
  end

  desc "gracefully stop the unicorn server"
  task :stop do
    on roles(:app) do
      # http://unicorn.bogomips.org/SIGNALS.html
      execute "kill -s QUIT `cat #{unicorn_config[:pid_file]}`; true"
    end
  end

  desc "gracefully restart the unicorn server"
  task :restart do
    on roles(:app) do
      # http://unicorn.bogomips.org/SIGNALS.html
      execute "kill -s USR2 `cat #{unicorn_config[:pid_file]}`; true"
    end
  end

  desc "immediately kill the unicorn server"
  task :kill, [:pid] do |t, args|
    on roles(:app) do
      # http://unicorn.bogomips.org/SIGNALS.html
      if args[:pid]
        execute "kill -s TERM #{args[:pid]}"
      else
        execute "kill -s TERM `cat #{unicorn_config[:pid_file]}`; true"
      end
    end
  end

  desc "Get the unicorn processes"
  task :pid do
    on roles(:app) do
      execute "ps aux | grep unicorn"
    end
  end
end

##############################
#
#   nginx, front-end proxy
#
##############################

namespace :nginx do

  task :configure do
    on roles(:app) do
      execute "sudo mkdir -p /tmp/nginx; sudo mkdir -p /tmp/nginx/cache; sudo chown -R #{fetch(:user)} /tmp/nginx/cache; sudo chown -R #{fetch(:user)} /etc/nginx/sites-available"

      nginx_conf_erb = ERB.new(File.read("#{root}/config/deploy/nginx.production.erb"))
      nginx_conf = nginx_conf_erb.result(binding)
      stream = StringIO.new(nginx_conf)
      upload!(stream, '/etc/nginx/sites-available/nginx.conf')

      upload!("#{root}/config/deploy/mime.types", '/etc/nginx/sites-available/mime.types')

      nginx_conf_erb = ERB.new(File.read("#{root}/config/nginx.conf.erb"))
      nginx_conf = nginx_conf_erb.result(binding)
      stream = StringIO.new(nginx_conf)
      upload!(stream, nginx_config[:config_file_path])
    end
  end

  task :start do
    on roles(:app) do
      execute "sudo service nginx start"
    end
  end

  task :stop do
    on roles(:app) do
      execute "sudo kill -QUIT `cat #{nginx_config[:pid_file]}`; true"
    end
  end

  task :reload do
    on roles(:app) do
      execute "sudo kill -HUP `cat #{nginx_config[:pid_file]}`; true"
    end
  end

  desc "Get the nginx processes"
  task :pid do
    on roles(:app) do
      execute "ps aux | grep nginx"
    end
  end
end