
module Murk
  module Model
    class StackCollection

      include Enumerable

      def initialize(stacks = nil)
        @stacks = stacks || []
      end

      def add(stack)
        @stacks << stack
      end

      def each(&block)
        @stacks.each(&block)
      end

      def find_by_name(name, env: nil)
        find do |stack|
          stack.name == name && stack.env == env
        end
      end

    end
  end
end
