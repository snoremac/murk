
# TODO: Test setting of reference stack parameters

RSpec.describe 'StackBuilder' do

  describe '#build' do

    it 'should set the stack name, env, and user' do
      expect(Stack).to receive(:new).with(name: 'vpc', env: 'uat', user: 'tester')
      StackBuilder.new(name: 'vpc', env: 'uat', user: 'tester').build
    end

    it 'should set the template filename if supplied' do
      stack = instance_double('Stack')
      expect(Stack).to receive(:new).with(name: 'app1', env: 'dev', user: 'tester').and_return(stack)
      expect(stack).to receive(:template_filename=).with('app.json')
      StackBuilder.new(name: 'app1', env: 'dev', user: 'tester').template('app.json').build
    end

    it 'should set simple stack parameters' do
      stack = instance_double('Stack')
      expect(Stack).to receive(:new).and_return(stack)
      expect(stack).to receive(:add_parameter)
        .with(SimpleStackParameter.new(:VPCCIDR, '10.0.0.0/16', env: 'dev'))
      expect(stack).to receive(:add_parameter)
        .with(SimpleStackParameter.new(:PublicSubnetACIDR, '10.0.0.0/24', env: 'dev'))
      params = proc do
        VPCCIDR '10.0.0.0/16'
        PublicSubnetACIDR '10.0.0.0/24'
      end
      StackBuilder.new(name: 'vpc', env: 'dev', user: 'tester').parameters(&params).build
    end

  end
end
