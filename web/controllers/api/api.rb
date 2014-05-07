require 'sinatra/json'
require 'oj'

# root API helpers
class StageCraftWebApp

  # get the current site status, and test for a variety of errors
  route :get, :post, '/api/status' do
    params['status'] = params['status'].to_i if params['status']
    api_reject if params['status'] == 400
    api_require_auth if params['status'] == 401
    api_require_found if params['status'] == 404
    api_require_permission if params['status'] == 405
    api_error if params['status'] == 500

    api_ok('status' => 'ok', 'query_string' => request.query_string, 'body' => request.body.read, 'ip' => request.ip)
  end

  private

  # halt with "ok" 200 status
  def api_ok(meta = nil, message = nil)
    payload = { :error => false, :status => 200 }

    if meta.is_a?(String)
      payload[:meta] = meta
      payload[:message] = meta
    else
      payload[:meta] = meta if meta
      payload[:message] = message if message
    end

    halt json(payload)
  end

  # halt with error 500 status
  def api_error(error = 'Internal Server Error')
    data = {
      :error => true,
      :status => 500,
      :message => error.to_s
    }

    # add trace messages to development mode
    data[:trace] = error.backtrace if development? and error.is_a?(StandardError)

    error 500, json(data)
  end

  # halt unless there is a valid session
  def api_require_auth(boom = 'Please login to do that.')
    require_login(nil, boom.to_s)
    @user
  end

  # halt unless a param is present
  def api_require_param(name, message = nil)
    api_reject(message || "Missing required parameter #{name}") if params.nil? or params[name].blank?
    params[name].strip!
    params[name]
  end

  # halt with error 400, which is for bad requests, like missing params, etc.
  def api_reject(boom = 'Bad request.')
    error 400, json(:error => true, :status => 400, :message => boom.to_s)
  end

  # halt with 404 response, unless the item is non-nil
  def api_require_found(item = nil)
    not_found if item.blank?
    item
  end

  # Check to see if @user has permission to access the api.
  # @param model [Object] the object to check for permission, ex: model.user_id == @user.id
  # @param options [Hash] Optional options.
  #   :user - check this User instead of @user
  #   :foreign_key - other will be checked such that other[foreign_key] == user.id (possession)
  #   :message - the message to return if permission is rejected
  def api_require_permission(model = nil, options = {})
    options[:user] = @user unless options[:user].present?
    options[:foreign_key] = :user_id unless options[:foreign_key].present?
    options[:message] = 'Not allowed, you don\'t seem to have permission.' unless options[:message]

    ok = false
    if model and options[:user] and options[:user].id
      model_user_id = model.send(options[:foreign_key])
      if model_user_id and model_user_id == options[:user].id
        ok = true
      elsif options[:user].is_admin?
        ok = true
      end
    end

    unless ok
      error 405, json(:error => true, :status => 405, :message => options[:message])
    end
  end

end

