
module CloudSeed
  module Builder

    class OptionsBuilder

      def initialize
        @options = {}
      end

      def build
        @options
      end

      def respond_to?(_method_sym)
        true
      end

      def method_missing(method_sym, *args)
        @options[method_sym] = args[0]
      end

    end

  end
end
