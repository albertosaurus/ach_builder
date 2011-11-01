module ACH
  # Base class for all record entities({ACH::File::Header file header record},
  # {ACH::File::Control file control record}, {ACH::Entry entries} etc.).
  # Any record entity must inherit {ACH::Record ACH::Record}.
  # All fields specified with {ACH::Record#fields fields} method must be 
  # declared in {ACH::Formatter Formatter}.
  #
  # == Example
  #   class Addenda < Record
  #     fields :record_type,
  #            :addenda_type_code,
  #            :payment_related_info,
  #            :addenda_sequence_num,
  #            :entry_details_sequence_num
  #     defaults :record_type => 7
  #   end
  #
  #   addenda = ACH::Addenda.new(:addenda_type_code => '05', :payment_related_info => 'PAYMENT_RELATED_INFO', :addenda_sequence_num => 1, :entry_details_sequence_num => 1)
  #   addenda.to_s! # => "705PAYMENT_RELATED_INFO                                                            00010000001"
  class Record
    include Validations
    include Constants
    
    # Raises when unknown field passed to {ACH::Record.fields Record.fields} method
    class UnknownField < ArgumentError
      def initialize field, class_name
        super "Unrecognized field '#{field}' in class #{class_name}"
      end
    end
    
    # Raises when value of record's field is not specified and there is no
    # default value.
    class EmptyField < ArgumentError
      def initialize field, record
        super "Empty field '#{field}' for #{record}"
      end
    end
    
    # Specifies fields of the record. Order is important. All fields
    # must be declared in {ACH::Formatter Formatter}.
    # == Example:
    #    fields :foo, :bar
    def self.fields *field_names
      return @fields if field_names.empty?
      @fields = field_names
      @fields.each{ |field| define_field_methods(field) }
    end
    
    # Sets default values for fields.
    # == Example:
    #    defaults :foo => "foo value",
    #             :bar => "bar value"
    def self.defaults default_values = nil
      return @defaults if default_values.nil?
      @defaults = default_values.freeze
    end

    def self.define_field_methods(field)
      raise UnknownField.new(field, name) unless Formatter::RULES.key?(field)
      define_method(field) do |*args|
        args.empty? ? @fields[field] : (@fields[field] = args.first)
      end
      define_method("#{field}=") do |val|
        @fields[field] = val
      end
    end
    private_class_method :define_field_methods
    
    def initialize fields = {}, &block
      defaults.each do |key, value|
        self.fields[key] = Proc === value ? value.call : value
      end
      self.fields.merge!(fields)
      instance_eval(&block) if block
    end
    
    # Builds a string from record object.
    def to_s!
      self.class.fields.map do |name|
        raise EmptyField.new(name, self) if @fields[name].nil?
        Formatter.format name, @fields[name]
      end.join
    end

    def from_str string

    end

    # Returns a hash where key is field's name and value is field's value.
    def fields
      @fields ||= {}
    end

    def defaults
      self.class.defaults
    end
    private :defaults
    
    def []= name, val
      fields[name] = val
    end
    private :[]=
  end
end
