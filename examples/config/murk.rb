
options do
  # Colon-delimited path specifying where to search for CloudFormation templates.
  # Relative paths are resolved against the directory containing the Murk
  # configuration file.
  template_path '../cloudformation'

  # An optional, global prefix prepended to all stack names.
  stack_prefix 'murk'
end

# Stacks in this environment will be named using the string 'qa'.
env 'qa' do
  # MURK will search for a template named 'vpc.json' in the paths specified
  # by the template_path option above.
  stack 'vpc' do

    parameters do
      # Simple parameter configuration.
      #
      # Parameter names should match those declared in the CloudFormation template.
      VPCCIDR '10.0.0.0/16'
    end

  end

  stack 'webapp-compute' do
    template 'compute.json'
    parameters do
      # Reference parameter using an output in the current environment.
      SubnetId { stack(name: 'webapp-network').output(:PublicSubnetId) }

      AMIId 'ami-e7ee9edd'
      KeyName ENV['USER']
      ASGMinSize '1'
      ASGMaxSize '1'
      ASGDesiredCapacity '1'
    end
  end

  stack 'webapp-network' do
    # Explicitly set the template filename, useful when creating several different
    # stacks from the same template.
    template 'network.json'

    parameters do
      # Reference parameters can also use the stack's fully qualified name, for
      # stacks declared in different environments or by different users
      VPCId { stack(qname: 'murk-qa-tester-vpc').output(:VPCId) }
      InternetGatewayId { stack(qname: 'murk-qa-tester-vpc').output(:InternetGatewayId) }

      PublicSubnetCIDR '10.0.0.0/24'
    end
  end
end
