module Murk
  module Builder

    class MurkBuilder

      attr_reader :user

      def initialize user
        @options_builder = OptionsBuilder.new
        @stack_builders = []
        @current_env = nil
        @user = user
      end

      def options(&block)
        @options_builder.instance_eval(&block)
        self
      end

      def env(name, &block)
        @current_env = name
        instance_eval(&block)
        @current_env = nil
        self
      end

      def stack(name, &block)
        stack_builder = StackBuilder.new(name: name, user: @user, env: @current_env)
        stack_builder.instance_eval(&block)
        @stack_builders << stack_builder
        self
      end

      def stacks
        @stacks ||= build
      end

      def build
        Murk.configure(@options_builder.build)

        stack_collection = Murk::Model::StackCollection.new

        @stack_builders.each do |builder|
          stack_collection.add(builder.build)
        end
        stack_collection
      end

    end
  end
end
