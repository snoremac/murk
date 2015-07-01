
RSpec.describe 'Template' do

  include_context 'path fixtures'
  include_context 'cloudformation stubs'

  describe '#path' do

    subject { Template.new('vpc.json').path }

    it 'should locate a template in the configured paths' do
      FileUtils.touch(['/tmp/templates-2/vpc.json'])
      expect(subject).to eq('/tmp/templates-2/vpc.json')
    end

    it 'should prioritise earlier paths over later ones' do
      FileUtils.touch(['/tmp/templates-1/vpc.json'])
      expect(subject).to eq('/tmp/templates-1/vpc.json')
    end

    it 'should raise an exception if the template isn\'t found' do
      expect { Template.new('nowhere.json').path }.to raise_error(TemplateError)
    end
  end

  describe '#body' do
  end

  describe '#parameters' do

    let(:parameter_keys) { [:VPCCIDR, :PublicSubnetCIDR, :PrivateSubnetCIDR] }
    let(:validate_template_output) { validate_template_with(parameter_keys) }

    before(:each) do
      FileUtils.touch(['/tmp/templates-1/vpc.json'])
    end

    it 'should validate the template descriptor when asked for valid parameters' do
      allow(cloudformation).to receive(:validate_template).and_return(validate_template_output)
      expect(cloudformation).to receive(:validate_template)
      Template.new('vpc.json').parameters
    end

    context 'with a valid template descriptor' do
      it 'should know the template parameters' do
        allow(cloudformation).to receive(:validate_template).and_return(validate_template_output)
        parameter_keys.each do |key|
          expect(Template.new('vpc.json').parameter?(key)).to be true
        end
      end
    end

    context 'with an invalid template descriptor' do
      it 'should raise an exception when asked for valid parameters' do
        ValidationError = Aws::CloudFormation::Errors::ValidationError
        allow(cloudformation).to receive(:validate_template).and_raise(ValidationError.new(nil, nil))
        expect { Template.new('vpc.json').parameters }.to raise_error(TemplateError)
      end
    end
  end
end
