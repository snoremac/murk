
RSpec.describe 'MurkBuilder' do

  describe '#build' do

    let(:stack_collection) { instance_double('StackCollection') }
    let(:qa_env) do
      proc do
        stack('vpc') {}
        stack('app') {}
      end
    end

    before(:each) do
      expect(StackCollection).to receive(:new).and_return(stack_collection)
    end

    context 'when building options' do

      let(:options) do
        proc do
          template_path '/tmp'
          stack_prefix 'murk'
        end
      end

      it 'should configure global options' do
        builder = MurkBuilder.new
        builder.options(&options).build
        expect(Murk.options[:template_path]).to eql('/tmp')
        expect(Murk.options[:stack_prefix]).to eql('murk')
      end

    end

    context 'when building bare stacks' do

      it 'should create the stack with the correct name' do
        expect(stack_collection).to receive(:add) do |stack|
          expect(stack.name).to eql('vpc')
        end

        builder = MurkBuilder.new
        builder.stack('vpc', &proc {}).build
      end
    end

    context 'when building stacks within an env' do

      it 'should create stacks with the correct names' do
        expect(stack_collection).to receive(:add) do |stack|
          expect(stack.name).to eql('vpc')
        end
        expect(stack_collection).to receive(:add) do |stack|
          expect(stack.name).to eql('app')
        end

        builder = MurkBuilder.new
        builder.env('qa', &qa_env).build
      end
    end
  end
end
