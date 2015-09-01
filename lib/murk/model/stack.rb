
require 'aws-sdk'
require 'murk/model/template'

module Murk
  module Model
    class Stack

      include Murk
      include Murk::AWS

      attr_reader :name, :env, :template, :user

      def initialize(name, env:, user:, template_filename: name + '.json')
        @name = name
        @env = env
        @template = Template.new(template_filename)
        @user = user
        @parameters = []
      end

      def template_filename=(template_filename)
        @template = Template.new(template_filename)
      end

      def add_parameter(parameter)
        if @template.parameter?(parameter.key)
          @parameters << parameter
        else
          fail StackError, "No such parameter '#{parameter.key}' for template '#{@template.filename}'"
        end
      end

      def parameter_value(parameter_key)
        @parameters.find { |parameter| parameter.key == parameter_key }.resolve
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

      def wait state
        cloudformation.wait_forever(:stack_create_complete, stack_name: qualified_name) { yield if block_given? }
      end

      def qualified_name
        qualified_name = ''
        if Murk.options[:stack_prefix]
          qualified_name += Murk.options[:stack_prefix] + '-'
        end
        qualified_name += "#{@env}-#{@user}-#{@name}"
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
      rescue Aws::CloudFormation::Errors::ValidationError => e
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
        {
          stack_name: qualified_name,
          template_body: @template.body,
          capabilities: ['CAPABILITY_IAM'],
          parameters: implicit_parameters + explicit_parameters
        }
      end

      def implicit_parameters
        implicit_parameters = {}
        implicit_parameters[:Prefix] = Murk.options[:stack_prefix] if @template.parameter?(:Prefix)
        implicit_parameters[:Env] = @env if @template.parameter?(:Env)
        implicit_parameters[:Name] = @name if @template.parameter?(:Name)
        implicit_parameters[:QualifiedName] = qualified_name if @template.parameter?(:QualifiedName)
        implicit_parameters.map { |key, value| { parameter_key: key, parameter_value: value } }
      end

      def explicit_parameters
        @parameters.map do |parameter|
          { parameter_key: parameter.key, parameter_value: parameter.resolve }
        end
      end

    end

    class StackError < StandardError
    end

  end
end
