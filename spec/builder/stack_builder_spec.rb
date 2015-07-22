
RSpec.describe 'StackBuilder' do

  describe '#build' do

    it 'should set the stack name' do
      expect(Stack).to receive(:new).with('vpc', env: nil)
      StackBuilder.new('vpc').build
    end

    it 'should set the stack env if supplied' do
      expect(Stack).to receive(:new).with('vpc', env: 'dev')
      StackBuilder.new('vpc', env: 'dev').build
    end

    it 'should set the stack parameters' do
      stack = instance_double('Stack')
      expect(Stack).to receive(:new).and_return(stack)
      expect(stack).to receive(:add_parameter).with(:VPCCIDR, '10.0.0.0/16')
      expect(stack).to receive(:add_parameter).with(:PublicSubnetACIDR, '10.0.0.0/24')
      params = proc do
        VPCCIDR '10.0.0.0/16'
        PublicSubnetACIDR '10.0.0.0/24'
      end
      StackBuilder.new('vpc').parameters(&params).build
    end

  end
end
