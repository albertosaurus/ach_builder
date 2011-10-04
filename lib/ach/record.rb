module ACH
  class Record
    include Validations
    include Constants
    
    class UnknownField < ArgumentError
      def initialize field, class_name
        super "Unrecognized field '#{field}' in class #{class_name}"
      end
    end
    
    class EmptyField < ArgumentError
      def initialize field, record
        super "Empty field '#{field}' for #{record}"
      end
    end
    
    def self.fields *field_names
      return @fields if field_names.empty?
      @fields = field_names
      @fields.each do |field|
        raise UnknownField.new(field, name) unless Formatter::RULES.key?(field)
        
        define_method(field) do |*args|
          args.empty? ? fields[field] : (fields[field] = args.first)
        end
        
        define_method("#{field}=") do |val|
          fields[field] = val
        end
      end
    end
    
    def self.defaults default_values = nil
      return @defaults if default_values.nil?
      @defaults = default_values.freeze
    end
    
    def initialize fields = {}, &block
      defaults.each do |key, value|
        self.fields[key] = Proc === value ? value.call : value
      end
      self.fields.merge!(fields)
      instance_eval(&block) if block
    end
    
    def defaults
      self.class.defaults
    end
    
    def fields
      @fields ||= {}
    end
    
    def []= name, val
      fields[name] = val
    end
    
    def to_s!
      self.class.fields.map do |name|
        raise EmptyField.new(name, self) if @fields[name].nil?
        Formatter.format name, @fields[name]
      end.join
    end
  end
end
