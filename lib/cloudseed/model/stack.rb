
require 'aws-sdk'
require 'cloudseed/model/template'

module CloudSeed
  module Model
    class Stack

      include CloudSeed
      include CloudSeed::AWS

      attr_reader :name

      def initialize(name, env: nil, parameters: {}, template_filename: name + '.json')
        @name = name
        @env = env
        @parameters = parameters
        @template = Template.new(template_filename)
      end

      # rubocop:disable Metrics/MethodLength
      def create_or_update
        fail "Stack '#{@name}' is in failed state" if failed?

        begin
          if exists?
            response = cloudformation.update_stack(config)
          else
            response = cloudformation.create_stack(config)
          end
        rescue Aws::CloudFormation::Errors::ValidationError => e
          if e.message =~ /No updates are to be performed/
            return
          else
            raise e
          end
        end
        response[:stack_id]
      end
      # rubocop:enable Metrics/MethodLength

      def config
        {
          stack_name: qualified_name,
          template_body: @template.body,
          capabilities: ['CAPABILITY_IAM'],
          parameters: @parameters.map { |key, value| { parameter_key: key, parameter_value: value } }
        }
      end

      def existing
        cloudformation.list_stacks.stack_summaries.select do |stack|
          stack.stack_name == qualified_name && stack.stack_status != 'DELETE_COMPLETE'
        end
      end

      def exists?
        existing.any?
      end

      def failed?
        existing.any? do |stack|
          stack.stack_status =~ /FAILED/
        end
      end

      def qualified_name
        qualified_name = ''
        if CloudSeed.options[:stack_prefix]
          qualified_name += CloudSeed.options[:stack_prefix] + '-'
        end
        if @env
          qualified_name += @env + '-'
        end
        qualified_name + @name
      end

      def output(key)
        return unless exists?
        outputs = cloudformation.describe_stacks(stack_name: qualified_name)[:stacks][0][:outputs]
        output = outputs.find { |o| o.output_key == key.to_s }
        output ? output.output_value : nil
      end

    end
  end
end
