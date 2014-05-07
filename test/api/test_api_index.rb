require_relative './api_test'

class ApiIndexTest < ApiTest

  def test_status
    get '/api/status'
    assert last_response.ok?
  end

  def test_errors
    get '/api/status', { 'status' => '400' }
    assert_equal 400, last_response.status

    [400, 401, 404, 405, 500].each do |code|
      json = get_api '/api/status', { 'status' => code.to_s }
      assert_equal code, last_response.status
      assert json['error']
      assert json['message']
      assert_equal code, json['status']
    end
  end

  def test_csrf
    assert_raises Rack::Csrf::InvalidCsrfToken do
      post '/api/status'
    end

    get '/api/status'
    assert last_response.ok?
    json = post_api '/api/status', {}
    assert last_response.ok?
    assert_kind_of Hash, json
  end

end