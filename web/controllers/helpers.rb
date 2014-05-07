# Controller helpers go here

class StageCraftWebApp
  helpers do
    include Rack::Utils
    alias_method :h, :escape_html

    # CSRF http://en.wikipedia.org/wiki/Cross-site_request_forgery
    def csrf_token
      Rack::Csrf.csrf_token(ENV)
    end

    def csrf_tag
      Rack::Csrf.csrf_tag(ENV)
    end

    def csrf_field
      Rack::Csrf.csrf_field()
    end

    def csrf_metatag
      Rack::Csrf.csrf_metatag(ENV)
    end

    # url encode a string
    def url_encode(str)
      URI::encode str.to_s
    end

    # json encode anything
    def json_encode(anything)
      Oj.dump(anything)
    end

    # get any current flash message
    def flash_msg
      class_map = [
        :success,
        :info,
        :warning,
        :warn,
        :error,
        :danger
      ]

      class_map.each do |key|
        return flash[key] if flash[key]
      end

      nil
    end

    # get the CSS style class for a flash message
    def flash_class
      flash_class = []

      class_map = {
        :success => 'alert-success',
        :info => 'alert-info',
        :warning => 'alert-warning',
        :warn => 'alert-warning',
        :error => 'alert-danger',
        :danger => 'alert-danger'
      }

      class_map.each do |key, val|
        flash_class << val if flash[key]
      end

      flash_class << 'hide' if flash_class.empty?
      flash_class.join(' ')
    end
  end

  private

  # access the StageCraft API client (i.e. call the api from other routes)
  def api
    raise SecurityError.new 'Attempted to call StageCraft API from a /api/* route, which may result in deadlock!' if is_api?
    return @api if @api

    require_relative '../../lib/apis/stage_craft_api'
    @api = StageCraftApi.new(:url => "#{$settings.url}/api")
    @api.set_session(get_user.smart_token) if has_session?
    @api
  end

  # is the current route an API route?
  def is_api?
    return @is_api unless @is_api.nil?
    @is_api = !!(request.path.match /\A\/api\//)
  end

  # halt with 404 response
  def not_found
    if is_api?
      error 404, json(:error => true, :status => 404, :message => 'Not found.')
    else
      error 404, File.read('public/404.html')
    end
  end

  # halt and redirect to login
  def require_login(path = '/login', msg = 'For your security, your login session has expired. Please login again.')
    return get_user if has_session?

    end_session!
    if is_api?
      error 401, json(:error => true, :status => 401, :message => msg)
    else
      flash[:warn] = msg
      redirect path
    end
  end

  def has_session?
    user = get_user
    !user.nil?
  end

  # start, continue, or stop a user session
  # @param [User] user    The user to set session for, or nil to end the session.
  def set_session(user)
    return end_session! if user.nil?
    @user = user
    session[:guid] = @user.guid
    session[:username] = @user.email || @user.phone
    response.headers['X-Smart-Token'] = @user.smart_token.to_s
    @user.update_visit_at
    api.set_session(@user.smart_token) unless is_api?
  end

  # get the current user based on present session data
  def get_user
    return @user if @user

    if request.env.key?('HTTP_X_SMART_TOKEN')
      # verify the token
      require_relative '../../lib/util/smart_token'
      smart_token = SmartToken.from_str(request.env['HTTP_X_SMART_TOKEN'])
      user = smart_token ? User.first(:guid => smart_token.guid) : nil
      @user = user if user and user.is_smart_token_valid? smart_token
    elsif session.key?(:guid)
      @user = User.first(:guid => session[:guid])
    end

    @user.update_visit_at if @user
    @user
  end

  # End the current user's session
  # @param [boolean] clear_everything   Set true to delete all session cookies.
  def end_session!(clear_everything = false)
    response.headers['HTTP_X_SMART_TOKEN'] = ''
    session[:guid] = nil
    session.clear if clear_everything
    @user = nil
  end

end