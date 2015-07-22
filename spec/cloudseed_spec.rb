
RSpec.describe 'CloudSeed' do

  include_context 'cloudformation stubs'

  describe '.load' do

    let(:parameter_keys) { [:VPCCIDR, :PublicSubnetCIDR] }
    let(:validate_template_output) { validate_template_with(parameter_keys) }

    it 'create and configure stacks' do
      allow(cloudformation).to receive(:validate_template).and_return(validate_template_output)
      stacks = CloudSeed.load(File.dirname(__FILE__) + '/../examples/config/cloudseed.rb')
      stack = stacks.find_by_name('vpc', env: ENV['USER'])

      expect(stack.name).to eql('vpc')
      expect(stack.qualified_name).to eql("cloudseed-#{ENV['USER']}-vpc")
      expect(stack.parameter_value(:VPCCIDR)).to eql('10.0.0.0/16')
      expect(stack.parameter_value(:PublicSubnetCIDR)).to eql('10.0.0.0/24')
      stack = stacks.find_by_name('vpc', env: 'qa')

      expect(stack.name).to eql('vpc')
      expect(stack.qualified_name).to eql('cloudseed-qa-vpc')
      expect(stack.parameter_value(:VPCCIDR)).to eql('10.0.1.0/16')
      expect(stack.parameter_value(:PublicSubnetCIDR)).to eql('10.0.1.0/24')
    end

  end
end
