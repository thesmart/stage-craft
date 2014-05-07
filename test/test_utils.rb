require 'minitest/autorun'
require_relative '../lib/util/guid'
require_relative '../config/initializers/stage_craft_app'

class TestUtils < MiniTest::Unit::TestCase
  def test_guid
    20.times do
      guid = Guid::generate()
      assert guid
      assert_equal 4, guid.length

      size = (3..20).to_a.sample
      guid = Guid::generate(size)
      assert guid
      assert_equal size, guid.length

      guid_a = Guid::generate(size, 'foobar')
      guid_b = Guid::generate(size, 'foobar')
      assert_equal guid_a, guid_b

      i = 10
      guid = Guid::generate_unique(size) do |guid|
        i -= 1
        i > 1
      end
      assert guid

      assert_raises(RuntimeError) do
        Guid::generate_unique(size) do |guid|
          false
        end
      end
    end
  end

end