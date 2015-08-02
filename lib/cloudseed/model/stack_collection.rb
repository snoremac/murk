
module CloudSeed
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

      def respond_to?(method_sym)
        @stacks.any? { |stack| stack.name == method_sym.to_s }
      end

      def method_missing(method_sym)
        @stacks.find { |stack| stack.name == method_sym.to_s }
      end

    end
  end
end
