
module Murk
  module Model
    class StackCollection

      include Enumerable

      def initialize
        @stacks = []
      end

      def add(stack)
        @stacks << stack
        stack.collection = self
      end

      def each(&block)
        @stacks.each(&block)
      end

      def find_by_name(name, env: nil)
        find do |stack|
          stack.name == name && stack.env == env
        end
      end

      def stack(name)
        @stacks.find { |stack| stack.name == name.to_s }
      end

    end
  end
end
