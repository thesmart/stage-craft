module Email
  module Errors
    # error generating an email view
    class EmailViewError < StandardError
    end

    # error sending email using an API
    class EmailSendError < StandardError
      def initialize(msg, resp)
        if resp
          super("#{msg}::#{resp.status}::#{resp.body}")
        else
          super("#{msg}::no response")
        end
      end
    end
  end
end