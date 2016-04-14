require 'spec_helper'

RSpec.describe Factory do
	let(:factory) do
		Factory.new(:name, :address, :zip) do
			def greeting
				'Hello ruby!'
			end
		end
	end

	let(:customer) { factory.new('Alex', 'Some street', 5555) }

	context '.new' do
		it 'creates a constant in Factory namespace with string as first argument' do
			factory_with_const = Factory.new('Customer', :name, :address)
			expect(factory_with_const).to eq(Factory::Customer)
		end

		it 'creates a new anonymous class' do
			expect(factory).to be_kind_of(Class)
		end

		it 'does not create a constant with symbol as first argument' do
			factory2 = Factory.new(:Customer2, :name, :address)
			expect(factory2.const_defined?('Customer2')).to be false
		end

		it 'raises NameError with invalid constant name as first argument' do
			expect { Factory.new('customer', :name, :address) }.to raise_error(NameError)
		end

		it 'allows class to be modified via the block' do
			expect(factory.new.greeting).to eq("Hello ruby!")
		end

		it 'creates reader methods' do
			expect(factory.new).to respond_to(:name)
		end

		it 'creates writer methods' do
			expect(factory.new).to respond_to(:name=)
		end

		it 'raises ArgumentError if no attributes provided' do
    	expect { Factory.new }.to raise_error(ArgumentError)
  	end
	end

	context '#initialize' do
		it 'sets instance variables to nil when argument not provided' do
			expect(factory.new.name).to be_nil
		end

		it 'raise error when factory size differs' do
			expect { factory.new('Alex', 'Some street', 1111, 'some info') }.to raise_error(ArgumentError)
		end
	end

	context '#[]' do
		it 'returns attribute value' do
			expect(customer[:name]).to eq('Alex')
			expect(customer['name']).to eq('Alex')
			expect(customer[0]).to eq('Alex')
			expect(customer[-3]).to eq('Alex')
		end

		it 'raise NameError when attribute does not exist' do
			expect { customer[:info] }.to raise_error(NameError)
		end

		it 'raise IndexError when index out of range' do
			expect { customer[4] }.to raise_error(IndexError)
		end

		it 'raise TypeError when variable not a string, symbol, or integer' do
			expect { customer[Object.new] }.to raise_error(TypeError)
		end
	end

	context '#[]=' do
		it 'assigns the passed value' do
			customer[:name] = 'Bob'
			expect(customer.name).to eq('Bob')
		end

		it 'raise NameError when attribute does not exist' do
			expect { customer[:info] = 'some info' }.to raise_error(NameError)
		end

		it 'raise IndexError when index out of range' do
			expect { customer[4] = 'some value' }.to raise_error(IndexError)
		end

		it 'raise TypeError when variable not a string, symbol, or integer' do
			expect { customer[Object.new] = 'object' }.to raise_error(TypeError)
		end
	end

	context '#members' do
		it 'returns an array of attribute names' do
			expect(customer.members).to eq([:name, :address, :zip])
		end
	end

	context '#dig' do
		before(:each) do
			klass = Factory.new(:a)
			@o = klass.new(klass.new({b: [1, 2, 3]}))
		end

		it 'returns the nested value' do
			expect(@o.dig(:a, :a, :b)).to eq([1, 2, 3])
		end

		it 'return nil when nested value does not exist' do
			expect(@o.dig(:b, 0)).to be_nil
		end

		it 'raise TypeError if first argument is not a symbol or a string' do
			expect { @o.dig(1, :b) }.to raise_error(TypeError)
		end
	end

	context '#length' do
		it 'returns the number of attributes' do
			expect(customer.length).to eq(3)
		end
	end

	context '#each' do
		it 'passes each value to the given block' do
	    i = -1
	    customer.each do |value|
	      expect(value).to eq(customer[i += 1])
	    end
		end

		it 'returns an Enumerator if not passed a block' do
			expect(customer.each).to be_instance_of(Enumerator)
		end
	end

	context '#each_pair' do
		it 'passes each key-value pair to the given block' do
	    customer.each_pair do |key, value|
	      expect(value).to eq(customer[key])
	    end
		end

		it 'returns an Enumerator if not passed a block' do
			expect(customer.each_pair).to be_instance_of(Enumerator)
		end
	end

	context '#to_a' do
		it 'returns the values as an array' do
			expect(customer.to_a).to eq(['Alex', 'Some street', 5555])
		end
	end

	context '#to_h' do
		it 'returns Hash with members as keys' do
			expect(customer.to_h).to eq({name: 'Alex', address: 'Some street', zip: 5555})
		end
	end

	context '#values_at' do
		it 'returns an array of values' do
			expect(customer.values_at(0, 1)).to eq(['Alex', 'Some street'])
		end
	end

	context '# ==' do
		it_behaves_like 'equal', '=='
	end

	context '#eql?' do
		it_behaves_like 'equal', 'eql?'

		it 'returns false if any corresponding elements are not #eql?' do
			similar_customer = factory.new('Alexander', 'Some street', 5555.0)
			expect(similar_customer.eql? customer).to be false
		end
	end

	context '#hash' do
		it 'returns the same value if structs are #eql?' do
			another_customer = factory.new('Alex', 'Some street', 5555)
			expect(another_customer.hash).to eq(customer.hash)
		end
	end

	context '#to_s' do
		it 'returns a string representation' do
			expect(customer.to_s).to eq ("#<factory  name=\"Alex\", address=\"Some street\", zip=5555>")
		end
	end
end