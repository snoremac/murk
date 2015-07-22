
options do
  template_path '../cloudformation'
  stack_prefix 'cloudseed'
end

env ENV['USER'] do

  stack 'vpc' do
    parameters do
      VPCCIDR '10.0.0.0/16'
      PublicSubnetCIDR '10.0.0.0/24'
    end
  end

end

env 'qa' do

  stack 'vpc' do
    parameters do
      VPCCIDR '10.0.1.0/16'
      PublicSubnetCIDR '10.0.1.0/24'
    end
  end

end
