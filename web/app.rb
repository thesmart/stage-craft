# This script starts the Stage Craft Web Application

require_relative '../config/initializers/stage_craft_web_app'
require 'sinatra/assetpack'
require 'coffee-script'
require 'sass'

class StageCraftWebApp < StageCraftApp
  register Sinatra::AssetPack

  configure do
    enable :static
    set :public_folder, "#{settings.root}/web/public"
    if settings.environment == 'production'
      set :server, 'unicorn'
    else
      set :server, 'thin'
    end
    set :bind, settings.http_bind
    set :port, settings.http_port
  end

  assets do
    serve '/js', :from => 'web/public/js'
    serve '/css', :from => 'web/public/css'
    serve '/fonts', :from => 'web/public/fonts'

    # Js Packages
    js :stage_craft, [
      '/js/vendor/jquery-1.11.0.min.js',
      # '/js/vendor/jquery-ui-1.10.4.custom.js',
      '/js/vendor/underscore-1.6.0.js',
      '/js/vendor/bootstrap-3.1.1.js',
      '/js/vendor/moment-2.5.0.min.js',
      '/js/vendor/parsely-2.0.0.rc5.js',
      '/js/vendor/garlic-1.2.2.min.js',
      '/js/app.js',
      '/js/mixins.js',
      '/js/on_load.js',
      '/js/partials/flash.js',
      '/js/partials/session.js'
    ]

    # Css Packages
    css :stage_craft, [
      '/css/vendor/bootstrap-3.1.1.min.css',
      '/css/vendor/font-awesome-4.0.3.css',
      '/css/app.css'
    ]

    js_compression  :uglify, [:drop_console => true]
    css_compression :sass
  end

  puts "Thank you for using Stage Craft in #{$settings.environment} mode..."
  run!
end
