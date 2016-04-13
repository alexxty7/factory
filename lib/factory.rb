class Factory
  def self.new(*attributes, &block)
    raise ArgumentError, 'wrong number of arguments (given 0, expected 1+)' if attributes.empty?

    if attributes.first.is_a?(String) && attributes.first.match(/^[A-Z]/)
      const = attributes.shift
    else
      const = nil
    end

    klass = Class.new do
      attr_accessor(*attributes)

      def initialize(*values)
        raise ArgumentError, 'factory size differs' if values.size > members.size
        values.each_with_index { |val, i| instance_variable_set("@#{members[i]}", val) }
      end

      define_method :members do
        attributes
      end

      def [](var)
        check_attribute(var)

        if var.is_a?(Fixnum)
          instance_variable_get("@#{members[var]}")
        else
          instance_variable_get("@#{var}")
        end
      end

      def []=(var, value)
        check_attribute(var)

        if var.is_a? Fixnum
          instance_variable_set("@#{members[var]}", value)
        else
          instance_variable_set("@#{var}", value)
        end
      end

      def dig(name, *names)
        begin
          name = name.to_sym
        rescue NoMethodError
          raise TypeError, "#{name} is not a symbol nor a string"
        end
        to_h.dig(name, *names)        
      end

      def select(&block)
        to_a.select(&block)
      end

      def length
        members.size
      end

      def each
        return to_enum(__method__) unless block_given?
        members.each { |m| yield send(m) }
      end

      def each_pair
        return to_enum(__method__) unless block_given?
        members.each { |m| yield(m, send(m)) }
      end

      def to_a
        members.map { |m| send(m) }
      end

      def to_h
        members.each_with_object({}) do |m, h|
          h[m] = send(m)
        end
      end

      def values_at(*arg)
        to_a.values_at(*arg)
      end

      def ==(other)
        return false unless other.kind_of?(self.class)
        values == other.values
      end

      def eql?(other)
        return false unless other.kind_of?(self.class)
        values.eql?(other.values)
      end

      def hash
        to_h.hash
      end

      def to_s
        str = "#<factory #{self.class.name}"
        first = true
        each_pair do |k, v|
          str << "," unless first
          first = false
          str << " #{k}=#{v.inspect}"
        end
        str << '>'
      end

      alias_method :values, :to_a
      alias_method :size, :length
      alias_method :inspect, :to_s

      class_eval(&block) if block_given?

      private
        def check_attribute(var)
          if var.is_a?(Fixnum)
            raise IndexError, "offset #{var} too large(small) for factory(size: #{size})" unless members[var]
          elsif var.is_a?(Symbol) || var.is_a?(String)
            raise NameError, "no member #{var} in factory" unless instance_variable_defined?("@#{var}")
          else
            raise TypeError, "no implicit conversion of #{var.class} into Integer"
          end
        end
    end

    const ? const_set(const, klass) : klass
  end
end
