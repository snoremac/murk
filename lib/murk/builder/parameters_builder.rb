
require 'murk/model/stack_parameter'

module Murk
  module Builder

    class ParametersBuilder

      def initialize(env: nil, user: nil)
        @env = env
        @user = user
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
          @parameters << Murk::Model::SimpleStackParameter.new(method_sym, args[0], env: @env)
        else
          @parameters << Murk::Model::ReferenceStackParameter.new(method_sym, block, env: @env, user: @user)
        end
      end

    end
  end
end
