# Description

Implement class 'Factory' which have the same behavior as 'Struct' class

# Usage
```ruby
Customer = Factory.new("Customer", :name, :address, :zip) do
  def greeting
    "Hello #{name}!"
  end
end

joe = Customer.new("Joe Smith", "123 Maple, Anytown NC", 12345)
joe.name
joe["name"]
joe[:name]
joe[0]
joe.greeting
  ```