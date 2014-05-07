require_relative '../config/initializers/stage_craft_test'
require_relative '../lib/util/smart_token'

class TestUser < MiniTest::Unit::TestCase
  def setup
    @user = User.create(:email => 'me@example.com')
  end

  def teardown
    @user.destroy
  end

  def test_create
    assert @user.id
    assert_equal 'me@example.com', @user.email
  end

  def test_password
    @user.password = 'foobar'
    assert @user.password.to_s != 'foobar', 'password should be hashed'
    assert @user.password == 'foobar', 'password object should match'
    assert @user.smart_token
    old_smart_token = @user.smart_token

    @user.password_randomize!
    assert @user.password != 'foobar', 'password should be random'
    assert @user.smart_token
    assert old_smart_token != @user.smart_token

    tokens = @user.smart_token.to_s.split('-')
    assert_equal 3, tokens.length
    assert_equal @user.smart_token.to_s, tokens.join('-')
  end

end