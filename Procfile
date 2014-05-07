# This is the development Procfile. See config/Procfile.erb for production Procfile.
beanstalkd: beanstalkd -l 127.0.0.1 -p 11300 1> ./tmp/beanstalkd.out.log 2>> ./tmp/beanstalkd.err.log
worker: bundle exec 'RACK_ENV="development" ruby ./daemons/worker.rb'
web: bundle exec rerun --pattern '*.{rb}' 'RACK_ENV="development" ruby ./web/app.rb'