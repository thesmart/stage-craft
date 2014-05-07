# Introduction

Stage Craft is based on Sinatra.rb. Get started quickly with API, offline workers, capistrano deployments, and more!

# Ruby Setup

To start a development environment on OSX, uninstall rvm, and use rbenv.

On Ubuntu:

```
$ git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
$ git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
$ echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
$ echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
$ rbenv install 2.0.0-p247
$ gem install --no-ri --no-rdoc bundler
$ rbenv rehash
```

On OSX:

```
$ brew update
$ brew install rbenv ruby-build
$ echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_login
$ echo 'eval "$(rbenv init -)"' >> ~/.bash_login
$ rbenv install 2.0.0-p247
$ gem install --no-ri --no-rdoc bundler
$ rbenv rehash
```

Now install the necessary gems:

```
$ cd stage-craft
$ gem install thrift -- --with-cppflags='-D_FORTIFY_SOURCE=0'
$ bundle install --path vendor/bundle
```

# Beanstalkd Setup

Next, install beanstalkd.

On Ubuntu:

```
$ sudo apt-get install beanstalkd
```

On OSX:

```
$ brew install beanstalkd
```

# Mysql Setup (Not Required)

Might need libmysqld-dev. On Ubuntu:

```
$ sudo apt-get install libmysqld-dev
```

On OSX:

```
$ sudo brew install mysql
```

Start mysql:

```
$ sudo /usr/local/bin/mysqld_safe start
```

# syslog/rsyslog setup (dev mode)

On Ubuntu:

```
tail -f /var/log/syslog
```

On OSX, run the following:
```
$ sudo cp /etc/syslog.conf /etc/syslog.conf.bkp
$ sudo nano /etc/syslog.conf
```

Add to the bottom and save:

```
local5.* /var/log/local5.log
```

Reload syslogd:

```
sudo launchctl unload  /System/Library/LaunchDaemons/com.apple.syslogd.plist
sudo launchctl load  /System/Library/LaunchDaemons/com.apple.syslogd.plist
```

Use ```console.app``` to view ```/var/log/local5.log```.

# App Startup (dev mode)

Start services by running:

```
$ RACK_ENV=development bundle exec foreman start
```

The web app will automatically restart whenever code changes. Start the web app by running:

```
$ bundle exec rerun --pattern '*.{rb}' 'RACK_ENV="development" ruby ./web/app.rb'
```

# Deployment

In order to deploy to production server for the first time, you have to setup an SSH alias:

```
$ echo "" >> ~/.ssh/config
$ echo "Host production_ssh" >> ~/.ssh/config
$ echo "Hostname XXX.XXX.XXX.XXX" >> ~/.ssh/config
$ echo "Port=22" >> ~/.ssh/config
$ echo "User=deploy" >> ~/.ssh/config
```

Deploy code as follows:

```
$ bundle exec cap production deploy
```

# Manage Beanstalkd

Ubuntu:

```
$ sudo apt-get install socat
```

OSX:

```
$ brew install socat
```

Then send commands:

```
$ socat - tcp4-connect:127.0.0.1:11300,crnl
```

Guide: https://github.com/kr/beanstalkd/blob/master/doc/protocol.txt
