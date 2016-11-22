
require 'api_cache'
require 'aws-sdk'
require 'murk/model/template'

module Murk
  module Model
    class Stack

      include Murk
      include Murk::AWS

      attr_reader :name, :env, :template, :user

      def initialize(qname: nil, name: nil, env: nil, user: nil, template_filename: nil)
        check_init_params(qname, name, env, user)
        if qname
          initialize_from_qname(qname)
        else
          initialize_from_qname_parts(name, env, user)
        end

        initialize_template(template_filename)
        @parameters = []
      end

      def check_init_params(qname, name, env, user)
        message = "Either specify ( qname: ) or ( name:, env:, user: ) when creating a Stack"
        if qname
          fail ArgumentError, message unless [name, env, user].all?(&:nil?)
        else
          fail ArgumentError, message if [name, env, user].any?(&:nil?)
        end
      end

      def initialize_from_qname(qname)
        qname_parts = qname.split('-')
        if qname_parts[0] == Murk.options[:stack_prefix]
          qname_parts.shift
        end
        @env = qname_parts[0]
        @user = qname_parts[1]
        @name = qname_parts[2..-1].join('-')
      end

      def initialize_from_qname_parts(name, env, user)
        @name = name
        @env = env
        @user = user
      end

      def initialize_template(template_filename)
        unless template_filename
          template_filename = @name + '.json'
        end
        @template = Template.new(template_filename)
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
        cloudformation.wait_forever(state, stack_name: qualified_name) { yield if block_given? }
      end

      def qualified_name
        qualified_name = ''
        if Murk.options[:stack_prefix]
          qualified_name += Murk.options[:stack_prefix] + '-'
        end
        qualified_name + "#{@env}-#{@user}-#{@name}"
      end

      def output(key)
        return unless exists?
        stack = APICache.get("stack_#{@qualified_name}", { cache: 10, valid: 30, period: 30 }) do
          cloudformation.describe_stacks(stack_name: qualified_name)[:stacks][0]
        end
        output = stack[:outputs].find { |o| o.output_key == key.to_s }
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
          return false
        else
          raise StackError, "Failed to update stack #{@name}"
        end
      end

      def existing
        stacks = APICache.get('list_stacks', { cache: 10, valid: 30, period: 30 }) do
          cloudformation.list_stacks(
            stack_status_filter: %w(CREATE_COMPLETE UPDATE_ROLLBACK_COMPLETE UPDATE_COMPLETE)
          )
        end
        stacks.stack_summaries.select { |stack| stack.stack_name == qualified_name }
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
        implicit_parameters[:User] = @user if @template.parameter?(:User)
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
