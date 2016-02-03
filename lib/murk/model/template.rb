
require 'aws-sdk'

module Murk
  module Model
    class Template

      include Murk
      include Murk::AWS

      attr_reader :filename

      def initialize(filename)
        @filename = filename
        @validated = Hash.new
      end

      def path
        @path ||= resolve_path(@filename)
      end

      def body
        File.read(path)
      end

      def parameters
        validate.parameters
      end

      def parameter?(parameter_key)
        parameters.any? { |param| param.parameter_key == parameter_key.to_s }
      end

      private

      def resolve_path(filename)
        template_paths = Murk.options[:template_path].split(':')
        template_paths.each do |path|
          real_path = File.absolute_path(path, Murk.config_dir)
          if File.exist?(File.join(real_path, filename))
            return File.join(real_path, filename)
          end
        end
        fail TemplateError, "Template '#{filename}' not found in path #{Murk.options[:template_path]}"
      end

      def validate
        if @validated.has_key?(@filename)
          @validate_output = @validated[@filename]
        else
          @validate_output ||= cloudformation.validate_template(template_body: body)
          @validated[@filename] = @validate_output
        end
      rescue Aws::CloudFormation::Errors::ValidationError
        raise TemplateError, "Failed to validate template at #{path}"
      end

    end

    class TemplateError < StandardError
    end

  end
end
