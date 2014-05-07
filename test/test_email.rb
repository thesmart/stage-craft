require_relative '../config/initializers/stage_craft_test'
require_relative '../lib/email/email'

class TestEmail < MiniTest::Unit::TestCase
  def test_render
    html = Email::Sender.render(:password_forgot, {
      :email_token => 'foobar'
    })
    assert html

    html = Email::Sender.render(:validation, {
      :email_token => 'foobar'
    })
    assert html
  end
end