# Require this file at the top of any executable StageCraft based web application (i.e. HTML5 over HTTP w/ cookies)

require 'sinatra/partial'
require 'sinatra/contrib'
require 'sinatra/param'
require 'rack/csrf'
require 'rack/flash'
require 'erubis'
require_relative './stage_craft_app'

# The base class for StageCraft web applications
class StageCraftWebApp < StageCraftApp
  register Sinatra::Partial
  register Sinatra::MultiRoute
  helpers Sinatra::Param

  configure do
    set :views, "#{settings.root}/web/views"
    set :session_secret, settings.http_session_secret
    set :show_exceptions, settings.http_show_exceptions
    enable :raise_errors, :dump_errors
    set :partial_template_engine, :erb
    enable :partial_underscores

    # session cookies
    set :sessions,
      :key => settings.http_session_name,
      :domain => settings.host,
      :path => '/',
      :expire_after => settings.http_session_expire_days.to_i.days,
      :secret => settings.http_session_secret

    # protect our forms against CSRF with this middleware.
    use Rack::Csrf, :raise => !production?, :skip => [
      # This is a list of exceptions to CSRF detection.
      # Add routes here that are called using external authentication protocols.
      # WARNING: DO NOT add routes that use cookie based sessions!
      # EXAMPLE: 'POST:/facebook/realtime-updates-callback'
    ], :skip_if => lambda { |request|
      # Custom headers that bypass CSRF
      request.env.key?('HTTP_X_SMART_TOKEN') or request.env.key?('HTTP_X_CSRF_BYPASS')
    }
    use Rack::Flash
  end

  # initializers
  require_relative './vendor'
  require_relative './controllers'
  require_relative './controllers_api'
end