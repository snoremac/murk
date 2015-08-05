
RSpec.describe 'Murk' do

  include_context 'cloudformation stubs'

  describe '.load' do

    let(:vpc_parameter_keys) { %i(VPCCIDR PublicSubnetCIDR) }
    let(:asg_parameter_keys) { %i(AMIId SubnetId KeyName ASGMinSize ASGMaxSize ASGDesiredCapacity) }
    let(:vpc_template_output) { validate_template_with(vpc_parameter_keys) }
    let(:asg_template_output) { validate_template_with(asg_parameter_keys) }
    let(:vpc_describe_output) { describe_stacks_with(PublicSubnetId: 'subnet-123456') }

    before(:each) do
      allow(cloudformation).to receive(:validate_template)
        .with(hash_including(template_body: a_string_matching(/VPC example/)))
        .and_return(vpc_template_output)
      allow(cloudformation).to receive(:validate_template)
        .with(hash_including(template_body: a_string_matching(/ASG example/)))
        .and_return(asg_template_output)
      allow(cloudformation).to receive(:list_stacks).and_return(
        list_stacks_with(
          "murk-#{ENV['USER']}-vpc": 'CREATE_COMPLETE'
        )
      )
      allow(cloudformation).to receive(:describe_stacks)
        .with(stack_name: "murk-#{ENV['USER']}-vpc")
        .and_return(vpc_describe_output)
    end

    it 'should create and configure stacks' do
      stacks = Murk.load(File.dirname(__FILE__) + '/../examples/config/murk.rb')

      stack = stacks.find_by_name('vpc', env: ENV['USER'])
      expect(stack.name).to eql('vpc')
      expect(stack.qualified_name).to eql("murk-#{ENV['USER']}-vpc")
      expect(stack.parameter_value(:VPCCIDR)).to eql('10.0.0.0/16')
      expect(stack.parameter_value(:PublicSubnetCIDR)).to eql('10.0.0.0/24')

      stack = stacks.find_by_name('asg', env: ENV['USER'])
      expect(stack.name).to eql('asg')
      expect(stack.qualified_name).to eql("murk-#{ENV['USER']}-asg")
      expect(stack.parameter_value(:SubnetId)).to eql('subnet-123456')

      stack = stacks.find_by_name('vpc', env: 'qa')
      expect(stack.name).to eql('vpc')
      expect(stack.qualified_name).to eql('murk-qa-vpc')
      expect(stack.parameter_value(:VPCCIDR)).to eql('10.0.1.0/16')
      expect(stack.parameter_value(:PublicSubnetCIDR)).to eql('10.0.1.0/24')
    end

  end
end
