
RSpec.describe 'Murk' do

  include_context 'cloudformation stubs'

  describe '.load' do

    let(:vpc_parameter_keys) { %i(VPCCIDR) }
    let(:network_parameter_keys) { %i(VPCId InternetGatewayId PublicSubnetCIDR) }
    let(:compute_parameter_keys) { %i(AMIId SubnetId KeyName ASGMinSize ASGMaxSize ASGDesiredCapacity) }
    let(:vpc_template_output) { validate_template_with(vpc_parameter_keys) }
    let(:network_template_output) { validate_template_with(network_parameter_keys) }
    let(:compute_template_output) { validate_template_with(compute_parameter_keys) }

    before(:each) do
      allow(cloudformation).to receive(:validate_template)
        .with(hash_including(template_body: a_string_matching(/VPC example/)))
        .and_return(vpc_template_output)
      allow(cloudformation).to receive(:validate_template)
        .with(hash_including(template_body: a_string_matching(/network example/)))
        .and_return(network_template_output)
      allow(cloudformation).to receive(:validate_template)
        .with(hash_including(template_body: a_string_matching(/compute example/)))
        .and_return(compute_template_output)
      allow(cloudformation).to receive(:describe_stacks)
        .with(stack_name: 'murk-qa-tester-vpc')
        .and_return(describe_stacks_with(
          stack_name: 'murk-qa-tester-vpc',
          stack_status: 'CREATE_COMPLETE',
          outputs: { VPCId: 'vpc-123456', InternetGatewayId: 'igw-123456' }
        ))
      allow(cloudformation).to receive(:describe_stacks)
        .with(stack_name: 'murk-qa-tester-webapp-network')
        .and_return(describe_stacks_with(
          stack_name: 'murk-qa-tester-webapp-network',
          stack_status: 'CREATE_COMPLETE',
          outputs: { PublicSubnetId: 'subnet-123456' }
        ))
    end

    it 'should create and configure stacks' do
      stacks = Murk.load(File.dirname(__FILE__) + '/../examples/config/murk.rb', 'tester').stacks

      stack = stacks.find_by_name('vpc', env: 'qa')
      expect(stack.name).to eql('vpc')
      expect(stack.template.filename).to eql('vpc.json')
      expect(stack.qualified_name).to eql('murk-qa-tester-vpc')
      expect(stack.parameter_value(:VPCCIDR)).to eql('10.0.0.0/16')

      stack = stacks.find_by_name('webapp-network', env: 'qa')
      expect(stack.name).to eql('webapp-network')
      expect(stack.template.filename).to eql('network.json')
      expect(stack.qualified_name).to eql("murk-qa-tester-webapp-network")
      expect(stack.parameter_value(:VPCId)).to eql('vpc-123456')
      expect(stack.parameter_value(:InternetGatewayId)).to eql('igw-123456')

      stack = stacks.find_by_name('webapp-compute', env: 'qa')
      expect(stack.name).to eql('webapp-compute')
      expect(stack.template.filename).to eql('compute.json')
      expect(stack.qualified_name).to eql("murk-qa-tester-webapp-compute")
      expect(stack.parameter_value(:SubnetId)).to eql('subnet-123456')
    end

  end
end
