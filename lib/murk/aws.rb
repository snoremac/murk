require 'aws-sdk'
require 'aws/extensions/cloudformation'

module Murk
  module AWS

    def cloudformation
      @cloudformation ||= Aws::CloudFormation::Client.new
    end

  end
end
