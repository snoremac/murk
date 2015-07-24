
# TODO: Validate the template even when no parameters are given

RSpec.describe 'Stack' do

  include_context 'cloudformation stubs'

  let(:vpc_template) { instance_double('Template', filename: 'vpc.json', body: 'vpc_template_body', parameter?: true) }
  let(:app_template) { instance_double('Template', filename: 'app.json', body: 'app_template_body', parameter?: true) }
  let(:database_template) { instance_double('Template', filename: 'database.json', body: 'database_template_body') }

  before(:each) do
    allow(cloudformation).to receive(:list_stacks).and_return(
      list_stacks_with('uat-vpc': 'CREATE_COMPLETE', 'uat-database': 'UPDATE_FAILED')
    )
    allow(Template).to receive(:new).with('vpc.json').and_return(vpc_template)
    allow(Template).to receive(:new).with('app.json').and_return(app_template)
    allow(Template).to receive(:new).with('database.json').and_return(database_template)
    CloudSeed.configure(stack_prefix: nil)
  end

  describe '#qualified_name' do

    context 'when no env has been specified' do
      subject { Stack.new('app').qualified_name }
      it { is_expected.to eql('app') }
    end

    context 'when no env has been specified but a global stack prefix is configured' do
      before(:each) { CloudSeed.configure(stack_prefix: 'goodcorp') }
      subject { Stack.new('app').qualified_name }
      it { is_expected.to eql('goodcorp-app') }
    end

    context 'when an env has been specified' do
      subject { Stack.new('app', env: 'prod').qualified_name }
      it { is_expected.to eql('prod-app') }
    end

    context 'when an env has been specified and a global stack prefix is configured' do
      before(:each) { CloudSeed.configure(stack_prefix: 'goodcorp') }
      subject { Stack.new('app', env: 'prod').qualified_name }
      it { is_expected.to eql('goodcorp-prod-app') }
    end

  end

  describe '#add_parameter' do

    let(:valid_parameters) { %i(AMIId ASGMinSize ASGMaxSize ASGDesiredCapacity) }
    let(:stack) { Stack.new('app') }

    it 'should accept parameters that are declared in the template' do
      allow(app_template).to receive(:parameter?) do |parameter_key|
        valid_parameters.include?(parameter_key)
      end
      valid_parameters.each do |param|
        stack.add_parameter(param, 'value')
      end
    end

    it 'should not accept parameters that are not declared in the template' do
      allow(app_template).to receive(:parameter?).with(:Invalid).and_return(false)
      expect { stack.add_parameter(:Invalid, 'value') }.to raise_error(StackError)
    end

  end

  describe '#create_or_update' do
    before(:each) do
      allow(cloudformation).to receive(:create_stack).and_return({})
      allow(cloudformation).to receive(:update_stack).and_return({})
    end

    it 'should derive the template filename from the stack name' do
      expect(Template).to receive(:new).with('vpc.json')
      Stack.new('vpc')
    end

    it 'should allow setting an explicit template filename' do
      explicit_template = instance_double(
        'Template', filename: 'explicit.json', body: 'explicit_template_body', parameter?: true
      )
      allow(Template).to receive(:new).with('explicit.json').and_return(explicit_template)

      expect(cloudformation).to receive(:create_stack).with hash_including(template_body: 'explicit_template_body')
      Stack.new('app', template_filename: 'explicit.json').create_or_update
    end

    it 'should update the stack where one exists with the same qualified name' do
      expect(cloudformation).to receive(:update_stack).and_return({})
      Stack.new('vpc', env: 'uat').create_or_update
    end

    it 'should create a new stack when none exists with the same qualified name' do
      expect(cloudformation).to receive(:create_stack).and_return({})
      Stack.new('app', env: 'uat').create_or_update
    end

    it 'should refuse to work with a stack in a failed state' do
      expect { Stack.new('database', env: 'uat').create_or_update }.to raise_error(StandardError)
    end

    context 'when configuring stack creation' do

      it 'should use the correct template_body' do
        expect(cloudformation).to receive(:create_stack).with hash_including(template_body: 'app_template_body')
        Stack.new('app').create_or_update
      end

      context 'and parameters have been specified' do
        it 'should pass the stack parameters' do
          input_parameters = { AMIId: 'ami-67e89f89', ASGMinSize: 1, ASGMaxSize: 4, ASGDesiredCapacity: 2 }
          allow(app_template).to receive(:parameter?) do |parameter_key|
            input_parameters.keys.include?(parameter_key)
          end

          expected_parameters = input_parameters.map { |key, value| { parameter_key: key, parameter_value: value } }
          expect(cloudformation).to receive(:create_stack).with hash_including(parameters: expected_parameters)

          stack = Stack.new('app')
          input_parameters.each { |key, value| stack.add_parameter(key, value) }
          stack.create_or_update
        end
      end
    end

    context 'when passing implicit parameters' do

      let(:template) { instance_double('Template', filename: 'template.json', body: '') }

      before(:each) do
        allow(Template).to receive(:new).with('template.json').and_return(template)
        implicit_parameter_keys = [:Prefix, :Name, :Env, :QualifiedName]
        allow(template).to receive(:parameter?) do |parameter_key|
          implicit_parameter_keys.include?(parameter_key)
        end
      end

      it 'should pass the global stack prefix if a \'Prefix\' parameter is declared' do
        CloudSeed.configure(stack_prefix: 'cloudseed')
        expect(cloudformation).to receive(:create_stack) do |config|
          expect(config[:parameters]).to include(parameter_key: :Prefix, parameter_value: 'cloudseed')
        end
        stack = Stack.new('template')
        stack.create_or_update
      end

      it 'should pass the stack name if a \'Name\' parameter is declared' do
        expect(cloudformation).to receive(:create_stack) do |config|
          expect(config[:parameters]).to include(parameter_key: :Name, parameter_value: 'template')
        end
        stack = Stack.new('template')
        stack.create_or_update
      end

      it 'should pass the stack env if a \'Env\' parameter is declared' do
        expect(cloudformation).to receive(:create_stack) do |config|
          expect(config[:parameters]).to include(parameter_key: :Env, parameter_value: 'uat')
        end
        stack = Stack.new('template', env: 'uat')
        stack.create_or_update
      end

      it 'should pass the stack qualified name if a \'QualifiedName\' parameter is declared' do
        CloudSeed.configure(stack_prefix: 'cloudseed')
        expect(cloudformation).to receive(:create_stack) do |config|
          expect(config[:parameters]).to include(
            parameter_key: :QualifiedName, parameter_value: 'cloudseed-uat-template'
          )
        end
        stack = Stack.new('template', env: 'uat')
        stack.create_or_update
      end
    end
  end

  describe '#delete' do
    it 'should delete the stack using the qualified name' do
      expect(cloudformation).to receive(:delete_stack).with(stack_name: 'uat-vpc')
      Stack.new('vpc', env: 'uat').delete
    end
  end

  describe '#output' do

    let(:outputs) { { VPCCId: 'vpc-72895717', PublicSubnetId: 'subnet-0f3a896a' } }

    before(:each) do
      allow(cloudformation).to receive(:describe_stacks).and_return(describe_stacks_with(outputs))
    end

    it "should provide a stack's outputs by name" do
      expect(Stack.new('vpc', env: 'uat').output(:VPCCId)).to eq(outputs[:VPCCId])
    end

  end

end
