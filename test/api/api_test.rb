require 'rack/test'
require 'minitest/autorun'
require_relative '../../config/initializers/stage_craft_web_app'

class ApiTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    @app ||= StageCraftWebApp.new
  end

  # get json and return the json result
  def get_api(path, params = {}, env = {})
    current_session.get("#{$settings.url}/#{path}", params, env)
    last_response.body ? Oj.load(last_response.body) : nil
  end

  # post json and return the json result
  def post_api(path, params = {})
    current_session.post("#{$settings.url}/#{path}", params, {
      'HTTP_X_CSRF_BYPASS' => 'yes'
    })
    last_response.body ? Oj.load(last_response.body) : nil
  end

  # signup and login a user for testing purposes
  def signup_user(options = {})
    options[:email] = options[:email] || $settings.customer_service_email
    options[:password] = options[:password] || 'foobar'

    # signup
    json = post_api '/api/session/signup', {
      'email' => options[:email],
      'password' => options[:password],
      'name' => options[:email].split('@')[0]
    }
    assert_equal 200, json['status'], json['message']

    login_user(options) unless options[:skip_login]
  end

  # login a user using email or phone and password
  def login_user(options = {})
    options[:email] = options[:email] || $settings.customer_service_email
    options[:password] = options[:password] || 'foobar'

    json = post_api '/api/session/login', {
      'username' => options[:email] || options[:phone],
      'password' => options[:password]
    }
    assert_equal 200, json['status'], json['message']
    json['meta']
  end

end