class StageCraftApi

  def initialize(options)
    require 'faraday'
    require 'faraday_middleware'

    @api = Faraday.new(:url => options[:url]) do |faraday|
      faraday.request :url_encoded
      faraday.response :json
      faraday.adapter :net_http
    end
    @api.headers['User-Agent'] = 'stage-craft/StageCraftApi (Faraday/0.8.8)'
    @api.headers['X-Csrf-Bypass'] = 'yes'

    # authentication mechanism
    @smart_token = nil
  end

  def set_session(smart_token)
    if smart_token
      @api.headers['X-Smart-Token'] = smart_token.to_s
    else
      @api.headers.delete('X-Smart-Token')
    end
  end

  def post(path, options = {})
    options[:method] = :post
    self.call(path, options)
  end

  def get(path, options = {})
    options[:method] = :get
    self.call(path, options)
  end

  # call the Stage Craft api
  # options:
  #   :method - :get, :post, ...
  #   :query  - Any query parameters
  #   :body   - POST parameters for :post/:put requests
  #   :request_headers
  def call(path, options = {})
    # defaults
    { :method => :get, :body => {}, :query => {}, :headers => {} }.each do |key, value|
      options[key] ||= value
    end

    resp = @api.run_request(options[:method], path, options[:body], options[:headers])
    if resp.status > 299
      raise Error.new("StageCraftApi::#{url}::#{options.to_json}", resp)
    elsif resp.body.nil? or !resp.body.is_a? Hash
      raise Error.new("StageCraftApi::#{url}::#{options.to_json}::#{resp.body.inspect}", resp)
    end

    resp.body.symbolize_keys!
    if resp.body[:error]
      raise Error.new("StageCraftApi::#{url}::#{options.to_json}", resp)
    end
    resp.body[:meta]
  end

  # error class for non-200 responses
  class Error < StandardError
    def initialize(msg, response)
      @response = response
      super msg
    end
  end

end
