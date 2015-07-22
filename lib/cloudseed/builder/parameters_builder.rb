
module CloudSeed
  module Builder

    class ParametersBuilder

      def initialize
        @parameters = {}
      end

      def build
        @parameters
      end

      def respond_to?(_method_sym)
        true
      end

      def method_missing(method_sym, *args)
        @parameters[method_sym] = args[0]
      end

    end

  end
end
