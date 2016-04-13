# Usage

p Factory.new("Customer", :name, :address) 
p dave = Factory::Customer.new("Dave", "123 Main") 
p dave.name
p dave["name"]
p dave[:name]
p dave[0]

Customer = Factory.new("Customer", :name, :address, :zip) do
  def greeting
    "Hello #{name}!"
  end
end

p joe = Customer.new("Joe Smith", "123 Maple, Anytown NC", 12345)
p joe.name
p joe["name"]
p joe[:name]
p joe[0]
p joe.greeting