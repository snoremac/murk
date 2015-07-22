
module CloudSeed
  module Builder

    class CloudSeedBuilder

      def initialize
        @options_builder = OptionsBuilder.new
        @stack_builders = []
        @current_env = nil
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
        stack_builder = StackBuilder.new(name, env: @current_env)
        stack_builder.instance_eval(&block)
        @stack_builders << stack_builder
        self
      end

      def build
        CloudSeed.configure(@options_builder.build)

        stack_collection = CloudSeed::Model::StackCollection.new
        @stack_builders.each do |builder|
          stack_collection.add(builder.build)
        end
        stack_collection
      end

    end

  end
end
