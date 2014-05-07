module Test
  module Mock
    class Tube
      attr_accessor :all_data
      attr_accessor :last_data

      def initialize
        @all_data = []
        @last_data = nil
      end

      def put(data, options = {})
        @all_data << data
        @last_data = data
      end
    end
  end
end