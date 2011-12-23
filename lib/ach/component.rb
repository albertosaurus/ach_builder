module ACH
  # Base class for ACH::File and ACH::Batch. Every component has its own number
  # of entities, header and control records. So it provides ACH::Component#header,
  # ACH::Component#control, ACH::Component.has_many methods to manage them.
  #
  # == Example
  #
  #    class File < Component
  #      has_many :batches
  #      # implementation
  #    end
  class Component
    extend ActiveSupport::Autoload

    include Validations
    include Constants

    autoload :HasManyAssociation

    # Exception raised on attempt to assign a value to nonexistent field.
    class UnknownAttributeError < ArgumentError
      def initialize field, obj
        super "Unrecognized attribute '#{field}' for #{obj}"
      end
    end
    
    class_attribute :default_attributes
    class_attribute :after_initialize_hooks
    self.default_attributes = {}
    self.after_initialize_hooks = []

    attr_reader :attributes

    def self.inherited(klass)
      klass.default_attributes = default_attributes.dup
      klass.after_initialize_hooks = after_initialize_hooks.dup
    end

    # Uses +method_missing+ pattern to specify default attributes for a
    # +Component+. If method name is one of the defined rules, saves it to
    # +default_attributes+ hash.
    #
    # These attributes are passed to inner components in a cascade way, i.e. when ACH
    # File was defined with default value for 'company_name', this value will be passed
    # to every Batch component within file, and from every Batch to corresponding batch
    # header record.
    #
    # Note that default values may be overwritten when building records.
    def self.method_missing(meth, *args)
      if Formatter.defined?(meth)
        default_attributes[meth] = args.first
      else
        super
      end
    end

    def initialize(fields = {}, &block)
      @attributes = {}.merge(self.class.default_attributes)
      fields.each do |name, value|
        raise UnknownAttributeError.new(name, self) unless Formatter.defined?(name)
        @attributes[name] = value
      end
      after_initialize
      instance_eval(&block) if block
    end

    def method_missing(meth, *args)
      if Formatter.defined?(meth)
        args.empty? ? @attributes[meth] : (@attributes[meth] = args.first)
      else
        super
      end
    end

    def before_header # :nodoc:
    end
    private :before_header

    # Sets header fields if fields or block passed. Returns header record.
    #
    # == Example 1
    #
    #   header :foo => "value 1", :bar => "value 2"
    #
    # == Example 2
    #
    #   header do
    #     foo "value 1"
    #     bar "value 2"
    #   end
    #
    # == Example 3
    #
    #   header # => just returns a header object
    def header(fields = {}, &block)
      before_header
      merged_fields = fields_for(self.class::Header).merge(fields)
      @header ||= self.class::Header.new(merged_fields)
      @header.tap do |head|
        head.instance_eval(&block) if block
      end
    end

    def build_header(str) # :nodoc:
      @header = self.class::Header.from_s(str)
    end

    def control
      @control ||= begin
        klass  = self.class::Control
        fields = klass.fields.select{ |f| respond_to?(f) || attributes[f] }
        klass.new Hash[*fields.zip(fields.map{ |f| send(f) }).flatten]
      end
    end

    def build_control(str) # :nodoc:
      @control = self.class::Control.from_s(str)
    end
    
    def fields_for(klass)
      if klass < Component
        attributes
      else
        attrs = attributes.find_all{ |k, v| klass.fields.include?(k) && attributes[k] }
        Hash[*attrs.flatten]
      end
    end

    def after_initialize # :nodoc:
      self.class.after_initialize_hooks.each{ |hook| instance_exec(&hook) }
    end
    
    # Creates has many association.
    #
    # == Example
    #
    #    class File < Component
    #      has_many :batches
    #    end
    #
    #    file = File.new do
    #      batch :foo => 1, :bar => 2
    #    end
    #
    #    file.batches  # => [#<Batch ...>]
    #
    # The example above extends File with #batches and #batch instance methods:
    # * #batch is used to add new instance of Batch.
    # * #batches is used to get an array of batches which belong to file.
    def self.has_many(plural_name, options = {})
      association = HasManyAssociation.new(plural_name, options)

      association_variable_name = "@#{plural_name}_association"
      association.delegation_methods.each do |method_name|
        delegate method_name, :to => association_variable_name
      end

      after_initialize_hooks << lambda{ instance_variable_set(association_variable_name, association.for(self)) }
    end
  end
end
