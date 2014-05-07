require_relative './api_test'

class ApiSessionTest < ApiTest

  def teardown
    User.destroy
    clear_cookies
  end

  def test_signup_and_login
    json = post_api '/api/session/signup', {
      'email' => $settings.customer_service_email,
      'password' => 'foobar',
      'name' => 'Santa\'s Lil Helper!'
    }

    assert !json['error']
    assert json['meta']

    meta = json['meta']
    assert_equal $settings.customer_service_email, meta['to']
    assert_equal $settings.customer_service_email, meta['from']
    assert_equal nil, meta['last_sent_at']

    json = post_api '/api/session/login', {
      'username' => $settings.customer_service_email,
      'password' => 'foobar'
    }
    assert_equal 200, json['status']
  end

  def test_me
    json = get_api '/api/me'
    assert_equal 401, json['status']

    user = signup_user
    assert_equal $settings.customer_service_email, user['email']

    json = get_api '/api/me'
    assert_equal 200, json['status']
    assert_equal $settings.customer_service_email, json['meta']['email']
    assert json['meta']['name']
    assert json['meta']['created_at']
    assert json['meta']['updated_at']
    assert json['meta']['visit_at']
  end
end