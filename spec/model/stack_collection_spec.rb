
RSpec.describe 'StackCollection' do

  describe '#find_by_name' do

    let(:stacks) do
      [
        Stack.new('stack1', env: 'uat', user: 'tester'),
        Stack.new('stack2', env: 'uat', user: 'tester')
      ]
    end
    let(:stack_collection) { StackCollection.new }

    before(:each) do
      stacks.each { |stack| stack_collection.add(stack) }
    end

    it 'should return the first matching stack' do
      expect(stack_collection.find_by_name('stack1', env: 'uat')).to be(stacks[0])
    end

  end
end
