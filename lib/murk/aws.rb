require 'aws-sdk'

module Murk
  module AWS

    def cloudformation
      @cloudformation ||= Aws::CloudFormation::Client.new
    end

  end
end
