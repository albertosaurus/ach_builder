module ACH
  # Base class for {ACH::File} and {ACH::Batch}. Every component has its own 
  # number of entities, header and control records. So it provides 
  # {ACH::Component#header}, {ACH::Component#control}, {ACH::Component.has_many}
  # methods to manage them.
  #
  # == Example:
  #    class File < Component
  #      has_many :batches
  #      # implementation
  #    end
  class Component
    extend ActiveSupport::Autoload

    include Validations
    include Constants

    # Exception raised on attempt to assign a value to nonexistent field.
    class UnknownAttributeError < ArgumentError
      def initialize field, obj
        super "Unrecognized attribute '#{field}' for #{obj}"
      end
    end

    # If Record should be attached to (preceded by) other Record, this
    # exception is raised on attempt to create attachment record without
    # having preceder record. For example, Addenda recourds should be
    # created after Entry records. Each new Addenda record will be attached
    # to the latest Entry record.
    class NoLinkError < ArgumentError
      def initialize link, klass
        super "No #{link} was found to attach a new #{klass}"
      end
    end
    
    class_attribute :default_attributes
    class_attribute :after_initialize_hooks
    self.default_attributes = {}
    self.after_initialize_hooks = []

    attr_reader :attributes
    attr_writer :control

    def self.inherited(klass)
      klass.default_attributes = default_attributes.dup
      klass.after_initialize_hooks = after_initialize_hooks.dup
    end

    def self.method_missing meth, *args
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

    def before_header
    end
    private :before_header

    # Sets header fields if fields or block passed. Returns header record.
    #
    # == Example 1:
    #
    #   header :foo => "value 1", :bar => "value 2"
    #
    # == Example 2:
    #
    #   header do
    #     foo "value 1"
    #     bar "value 2"
    #   end
    #
    # == Example 3:
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

    def build_header(str)
      @header = self.class::Header.from_s(str)
    end

    def control
      @control ||= begin
        klass  = self.class::Control
        fields = klass.fields.select{ |f| respond_to?(f) || attributes[f] }
        klass.new Hash[*fields.zip(fields.map{ |f| send(f) }).flatten]
      end
    end

    def build_control(str)
      @control = self.class::Control.from_s(str)
    end
    
    def fields_for(component_or_class)
      klass = component_or_class.is_a?(Class) ? component_or_class : ACH.to_const(component_or_class.camelize)
      if klass < Component
        attributes
      else
        attrs = attributes.find_all{ |k, v| klass.fields.include?(k) && attributes[k] }
        Hash[*(attrs.flatten)]
      end
    end

    def after_initialize
      self.class.after_initialize_hooks.each{ |hook| instance_exec(&hook) }
    end
    
    # Creates has many association.
    #
    # == Example:
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
      attr_reader plural_name

      proc_defaults = options[:proc_defaults]
      linked_to = options[:linked_to]

      singular_name = plural_name.to_s.singularize
      camelized_singular_name = singular_name.camelize.to_sym
      klass = ACH.to_const(camelized_singular_name)

      define_method("build_#{singular_name}") do |str|
        obj = klass.from_s(str)
        send("container_for_#{singular_name}") << obj
      end

      define_method("container_for_#{singular_name}") do
        return send(plural_name) unless linked_to

        last_link = send(linked_to).last
        raise NoLinkError.new(linked_to.to_s.singularize, klass.name) unless last_link
        send(plural_name)[last_link] ||= []
      end

      define_method(singular_name) do |*args, &block|
        fields = args.first || {}

        defaults = proc_defaults ? instance_exec(&proc_defaults) : {}

        klass.new(fields_for(singular_name).merge(defaults).merge(fields)).tap do |component|
          component.instance_eval(&block) if block
          send("container_for_#{singular_name}") << component
        end
      end
      
      after_initialize_hooks << lambda{ instance_variable_set("@#{plural_name}", linked_to ? {} : []) }
    end
  end
end
