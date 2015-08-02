
module CloudSeed
  module Model

    class SimpleStackParameter

      attr_reader :key, :value

      def initialize(key, value)
        @key = key
        @value = value
      end

      def resolve(stack_collection)
        @value
      end

      def ==(other)
        @key == other.key && @value == other.value
      end

    end

    class ReferenceStackParameter

      attr_reader :key, :block

      def initialize(key, block)
        @key = key
        @block = block
      end

      def resolve(stack_collection)
        stack_collection.instance_eval(&@block)
      end

    end
  end
end
