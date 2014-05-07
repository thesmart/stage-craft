require 'test/unit'
require_relative '../config/initializers/stage_craft_app'
require_relative '../lib/util/smart_token'

class TestSmartToken < Test::Unit::TestCase
  def test_basics
    st = SmartToken.new('foobar')
    assert_respond_to st, :guid
    assert_respond_to st, :time
    assert_respond_to st, :signature
    assert_respond_to st, :is_expired?
    assert_respond_to st, :is_signed?
    assert_respond_to st, :is_valid?

    nt = SmartToken.from_str(st.to_s)
    assert_equal st.guid, nt.guid
    assert !st.is_valid?('secret')
    assert !nt.is_valid?('secret')
  end

  def test_signature
    st = SmartToken.new('foobar').sign!('secret')
    assert st.is_valid?('secret')
    assert !st.is_valid?('fake secret')

    nt = SmartToken.from_str(st.to_s)
    assert nt.is_valid?('secret')
    assert !nt.is_valid?('fake secret')

    assert_equal st.to_s, nt.to_s
  end

  def test_timeout
    st = SmartToken.new('foobar', 72.hours.ago.to_i + 1).sign!('secret')
    assert st.is_valid?('secret')
    assert !st.is_expired?

    sleep(1)
    assert !st.is_valid?('secret')
    assert st.is_expired?
  end

end