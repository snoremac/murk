
require 'aws-sdk'

module CloudSeed
  module Model
    class Template

      include CloudSeed
      include CloudSeed::AWS

      attr_reader :filename

      def initialize(filename)
        @filename = filename
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
        template_paths = CloudSeed.options[:template_path].split(':')
        template_paths.each do |path|
          real_path = File.absolute_path(path, CloudSeed.config_dir)
          if File.exist?(File.join(real_path, filename))
            return File.join(real_path, filename)
          end
        end
        fail TemplateError, "Template '#{filename}' not found in path #{CloudSeed.options[:template_path]}"
      end

      def validate
        @validate_output ||= cloudformation.validate_template(template_body: body)
      rescue Aws::CloudFormation::Errors::ValidationError
        raise TemplateError, "Failed to validate template at #{path}"
      end

    end

    class TemplateError < StandardError
    end

  end
end
