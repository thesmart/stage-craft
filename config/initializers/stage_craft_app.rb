# Require this file at the top of any executable StageCraft based application (i.e. web apps, tests, scripts, daemons, etc.)

ENV['RACK_ENV'] = ENV['RACK_ENV'] ? ENV['RACK_ENV'] : 'development'
ENV['RACK_ENV'] = 'test' if $0.include?('/test/')

# change working dir when scripts are run from one of these folders
Dir.chdir("#{__dir__}/../../web") if $0.include?('/web/')
Dir.chdir("#{__dir__}/../../scripts") if $0.include?('/scripts/')
Dir.chdir("#{__dir__}/../../daemons") if $0.include?('/daemons/')
Dir.chdir("#{__dir__}/../../test") if $0.include?('/test/')

require 'sinatra/base'
require 'sinatra/config_file'
require 'active_support/core_ext/object'
require 'active_support/core_ext/numeric'
require 'active_support/core_ext/date'
require 'active_support/core_ext/time'
require 'active_support/core_ext/date_time'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/string'
require 'active_support/core_ext/array'
require 'active_support/core_ext/integer'
require 'active_support/core_ext/uri'
require_relative '../../lib/core/string'
require_relative '../../lib/util/guid'

# The class for any Stage Craft application (i.e. web apps, tests, scripts, daemons, etc.)
class StageCraftApp < Sinatra::Base
  register Sinatra::ConfigFile

  configure do
    # disabled by default
    disable :run
    set :root, File.absolute_path("#{__dir__}/../../")
    set :environment, ENV['RACK_ENV'].to_sym

    # settings
    config_file "#{settings.root}/config/settings.yml"
    $settings = settings

    # required folders
    set :tmp_path, "#{settings.root}/tmp"
    require_relative '../../config/initializers/logging'

    enable :logging unless production?
    enable :dump_errors
  end

  # environment
  def development?; $settings.environment == :development end
  def production?;  $settings.environment == :production  end
  def test?;        $settings.environment == :test        end

  # initializers
  require_relative '../../config/initializers/models'
  require_relative '../../config/initializers/queues'
end