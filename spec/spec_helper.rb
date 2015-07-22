
require 'simplecov'
SimpleCov.start
require 'pry'
require 'aws-sdk'
require 'cloudseed'

CloudSeedBuilder = CloudSeed::Builder::CloudSeedBuilder
StackBuilder = CloudSeed::Builder::StackBuilder

Stack = CloudSeed::Model::Stack
StackCollection = CloudSeed::Model::StackCollection
Template = CloudSeed::Model::Template
TemplateError = CloudSeed::Model::TemplateError
StackError = CloudSeed::Model::StackError

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
    CloudSeed.configure(template_path: paths.join(':'))
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
        stack_name: 'vpc',
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

CloudSeed.logger = Logger.new(File.dirname(__FILE__) + '/../spec.log')
