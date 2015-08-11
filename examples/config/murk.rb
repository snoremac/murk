
options do
  # Colon-delimited path specifying where to search for CloudFormation templates
  # Relative paths are resolved against the directory containing the Murk
  # configuration file
  template_path '../cloudformation'
  # An optional, global prefix prepended to all stack names.
  stack_prefix 'murk'
end

# Stacks in this environment will be named after the current user
env ENV['USER'] do

  # MURK will search for a template named 'vpc.json' in the paths specified
  # by the template_path option above
  stack 'vpc' do
    parameters do
      # Simple parameter configuration
      # Parameter names should match those declared in the CloudFormation template
      VPCCIDR '10.0.0.0/16'
      PublicSubnetCIDR '10.0.0.0/24'
    end
  end

  stack 'web-asg' do
    # Explicitly set the template filename, useful when creating several different
    # stacks from the same template
    template 'asg.json'
    parameters do
      AMIId 'ami-e7ee9edd'
      # Reference parameter configuration
      # This will cause Murk to look up the named output of the referenced stack
      SubnetId { vpc.output(:PublicSubnetId) }
      KeyName ENV['USER']
      ASGMinSize '1'
      ASGMaxSize '1'
      ASGDesiredCapacity '1'
    end
  end

end

# Stacks in this environment will be named using the string 'qa'
env 'qa' do

  stack 'vpc' do
    parameters do
      VPCCIDR '10.0.1.0/16'
      PublicSubnetCIDR '10.0.1.0/24'
    end
  end

  stack 'asg' do
    parameters do
      AMIId 'ami-e7ee9edd'
      SubnetId { vpc.output(:PublicSubnetId) }
      KeyName 'qa'
      ASGMinSize '2'
      ASGMaxSize '4'
      ASGDesiredCapacity '2'
    end
  end

end
