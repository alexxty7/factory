RSpec.shared_examples 'equal' do |method|
	let(:operator) { method }
	let(:true_customer) { factory.new('Alex', 'Some street', 5555) }
	let(:diff_customer) { factory.new('Alexander', 'Some street', 5555) }
	let(:false_customer) do
		customer = Struct.new(:name, :address, :zip)
		false_customer = customer.new('Alex', 'Some street', 5555)
	end

	it 'returns true if the other has all the same fields and is the same object' do
		expect(true_customer.send(operator, customer)).to be true
	end

	it 'returns false if the other is a different object' do
		expect(false_customer.send(operator, customer)).to be false
	end

	it 'returns false if the other has different fields' do
		expect(diff_customer.send(operator, customer)).to be false
	end
end