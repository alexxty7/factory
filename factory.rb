class Factory
  def self.new(*attributes, &block)
    Class.new do
      attr_accessor(*attributes)

      define_method :initialize do |*values|
        values.each_with_index { |val, i| instance_variable_set("@#{attributes[i]}", val) }
      end

      define_method "[]" do |var|
        if var.is_a? Fixnum
          instance_variable_get("@#{attributes[var]}")
        else
          instance_variable_get("@#{var}")
        end
      end

      define_method "[]=" do |var, value|
        if var.is_a? Fixnum
          instance_variable_set("@#{attributes[var]}", value)
        else
          instance_variable_set("@#{var}", val)
        end
      end

      class_eval(&block) if block_given?
    end
  end
end
