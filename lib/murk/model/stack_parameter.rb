
module Murk
  module Model

    class SimpleStackParameter

      attr_reader :key, :value, :env

      def initialize(key, value, env: nil)
        @key = key
        @value = value
        @env = env
      end

      def resolve
        @value
      end

      def ==(other)
        @key == other.key && @value == other.value && @env == other.env
      end

    end

    class ReferenceStackParameter

      attr_reader :key, :block

      def initialize(key, block, env: nil)
        @key = key
        @block = block
        @env = env
      end

      def resolve
        instance_eval(&@block)
      end

      def env(name)
        @env = name
        self
      end

      def stack(name)
        Stack.new(name, env: @env)
      end

    end
  end
end
