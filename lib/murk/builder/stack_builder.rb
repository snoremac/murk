
module Murk
  module Builder

    class StackBuilder

      def initialize(name:, user:, env:)
        @stack_name = name
        @env = env
        @user = user
        @parameters_builder = ParametersBuilder.new(env: @env, user: user)
      end

      def build
        stack = Murk::Model::Stack.new(name: @stack_name, env: @env, user: @user)

        if @template_filename
          stack.template_filename = @template_filename
        end
        @parameters_builder.build.each do |parameter|
          stack.add_parameter(parameter)
        end
        stack
      end

      def template(template_filename)
        @template_filename = template_filename
        self
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
