module Aws
  module CloudFormation
    class Client

      def wait_forever state, stack_name
        wait_until(state, stack_name) do |w|
          # disable max attempts
          w.max_attempts = nil
          w.before_wait do |attempts, response|
            yield attempts, response if block_given?
          end
        end
      end
    end
  end
end

