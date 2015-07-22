
module CloudSeed
  module Builder

    class StackBuilder

      def initialize(stack_name, env: nil)
        @stack_name = stack_name
        @env = env
        @parameters_builder = ParametersBuilder.new
      end

      def build
        stack = CloudSeed::Model::Stack.new(@stack_name, env: @env)
        @parameters_builder.build.each do |key, value|
          stack.add_parameter(key, value)
        end
        stack
      end

      def parameters(&block)
        @parameters_builder.instance_eval(&block)
        self
      end

    end

    class ConfigError < StandardError
    end

  end
end
