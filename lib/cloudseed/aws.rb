require 'aws-sdk'

module CloudSeed
  module AWS

    def cloudformation
      @cloudformation ||= Aws::CloudFormation::Client.new
    end

  end
end
