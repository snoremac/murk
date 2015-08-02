
require 'cloudseed/model/stack_parameter'

module CloudSeed
  module Builder

    class ParametersBuilder

      def initialize
        @parameters = []
      end

      def build
        @parameters
      end

      def respond_to?(_method_sym)
        true
      end

      def method_missing(method_sym, *args, &block)
        if args.length > 0
          @parameters << CloudSeed::Model::SimpleStackParameter.new(method_sym, args[0])
        else
          @parameters << CloudSeed::Model::ReferenceStackParameter.new(method_sym, block)
        end
      end

    end
  end
end
