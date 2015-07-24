
require 'aws-sdk'
require 'cloudseed/model/template'

module CloudSeed
  module Model
    class Stack

      include CloudSeed
      include CloudSeed::AWS

      attr_reader :name, :env

      def initialize(name, env: nil, template_filename: name + '.json')
        @name = name
        @env = env
        @template = Template.new(template_filename)
        @parameters = {}
      end

      def add_parameter(key, value)
        if @template.parameter?(key)
          @parameters[key] = value
        else
          fail StackError, "No such parameter '#{key}' for template '#{@template.filename}'"
        end
      end

      def parameter_value(parameter_key)
        @parameters[parameter_key]
      end

      def create_or_update
        fail StackError, "Stack '#{@name}' is in failed state" if failed?
        exists? ? update : create
      end

      def delete
        fail StackError "Stack #{@name} does not exist" unless exists?
        cloudformation.delete_stack(stack_name: qualified_name)
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

      private

      def create
        cloudformation.create_stack(config)
      rescue Aws::CloudFormation::Errors::ValidationError
        raise StackError, "Failed to create stack #{@name}"
      end

      def update
        cloudformation.update_stack(config)
      rescue Aws::CloudFormation::Errors::ValidationError
        if e.message =~ /No updates are to be performed/
          return
        else
          raise StackError, "Failed to update stack #{@name}"
        end
      end

      def existing
        cloudformation.list_stacks.stack_summaries.select do |stack|
          stack.stack_name == qualified_name && stack.stack_status != 'DELETE_COMPLETE'
        end
      end

      def config
        all_parameters = @parameters.merge(implicit_parameters)
        {
          stack_name: qualified_name,
          template_body: @template.body,
          capabilities: ['CAPABILITY_IAM'],
          parameters: all_parameters.map { |key, value| { parameter_key: key, parameter_value: value } }
        }
      end

      def implicit_parameters
        implicit_parameters = {}
        implicit_parameters[:Prefix] = CloudSeed.options[:stack_prefix] if @template.parameter?(:Prefix)
        implicit_parameters[:Env] = @env if @template.parameter?(:Env)
        implicit_parameters[:Name] = @name if @template.parameter?(:Name)
        implicit_parameters[:QualifiedName] = qualified_name if @template.parameter?(:QualifiedName)
        implicit_parameters
      end

    end

    class StackError < StandardError
    end

  end
end
