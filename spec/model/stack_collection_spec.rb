
RSpec.describe 'StackCollection' do

  describe '#find_by_name' do

    let(:stacks) do
      [
        Stack.new('stack1'),
        Stack.new('stack1', env: 'uat'),
        Stack.new('stack2', env: 'uat'),
        Stack.new('stack1', env: 'uat')
      ]
    end
    let(:stack_collection) { StackCollection.new }

    before(:each) do
      stacks.each { |stack| stack_collection.add(stack) }
    end

    it 'should return the first matching stack' do
      expect(stack_collection.find_by_name('stack1', env: 'uat')).to be(stacks[1])
    end

    it 'should find stacks with no env if none is supplied' do
      expect(stack_collection.find_by_name('stack1')).to be(stacks[0])
    end
  end
end
