
require 'api_cache'
require 'simplecov'
SimpleCov.start
require 'pry'
require 'aws-sdk'
require 'murk'

MurkBuilder = Murk::Builder::MurkBuilder
StackBuilder = Murk::Builder::StackBuilder

Stack = Murk::Model::Stack
StackCollection = Murk::Model::StackCollection
SimpleStackParameter = Murk::Model::SimpleStackParameter
ReferenceStackParameter = Murk::Model::ReferenceStackParameter
Template = Murk::Model::Template
TemplateError = Murk::Model::TemplateError
StackError = Murk::Model::StackError

APICache.store = APICache::NullStore.new

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_doubled_constant_names = true
    mocks.verify_partial_doubles = true
  end
  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.disable_monkey_patching!
  config.default_formatter = 'doc' if config.files_to_run.one?
  config.fail_fast = false
  config.order = :defined
  Kernel.srand config.seed
end

RSpec.shared_context 'path fixtures' do
  before(:each) do
    paths = (1..3).map { |numb| "/tmp/templates-#{numb}" }
    paths.each do |path|
      FileUtils.rm_rf(path)
      FileUtils.mkdir_p(path)
    end
    Murk.configure(template_path: paths.join(':'))
  end
end

RSpec.shared_context 'cloudformation stubs' do

  def validate_template_with(parameter_keys)
    Aws::CloudFormation::Types::ValidateTemplateOutput.new(
      parameters: parameter_keys.map do |key|
        Aws::CloudFormation::Types::TemplateParameter.new(parameter_key: key.to_s)
      end
    )
  end

  def list_stacks_with(stack_statuses)
    Seahorse::Client::Response.new(
      data: Aws::CloudFormation::Types::ListStacksOutput.new(
        stack_summaries: stack_statuses.map do |key, value|
          Aws::CloudFormation::Types::StackSummary.new(stack_name: key.to_s, stack_status: value)
        end
      )
    )
  end

  def describe_stacks_with(stack_outputs)
    Seahorse::Client::Response.new(
      data: Aws::CloudFormation::Types::DescribeStacksOutput.new(stacks: [
        stack_name: 'vpc-uat-foo',
        outputs: stack_outputs.map do |key, value|
          Aws::CloudFormation::Types::Output.new(output_key: key.to_s, output_value: value)
        end
      ])
    )
  end

  let(:cloudformation) { double('cloudformation') }

  before(:each) do
    allow(Aws::CloudFormation::Client).to receive(:new).and_return(cloudformation)
  end
end

Murk.logger = Logger.new(File.dirname(__FILE__) + '/../spec.log')
