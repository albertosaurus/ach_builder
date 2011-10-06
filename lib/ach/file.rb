module ACH
  class File < Component
    has_many :batches, lambda{ {:batch_number => batches.length + 1} }
    subcomponent_list << :transmission_header

    def self.method_missing(meth, attrs_or_value = {}, &block)
      bs = ACH::File::BlankStruct.new
      bs.instance_exec(&block) if block
      attrs_or_value.deep_merge!(bs.to_hash) if attrs_or_value.is_a? Hash
      default_opts[meth.to_sym] = attrs_or_value
    end

    def self.inherited(klass)
      after_initialize_hooks.each{ |hook| klass.after_initialize_hooks << hook }
      subcomponent_list.each{ |subcomp| klass.subcomponent_list << subcomp }
    end

    def self.default_opts
      class << self; @default_opts ||= {}; end
    end

    def initialize(fields = {}, &block)
      super self.class.default_opts.deep_merge(fields), &block
    end

    def transmission_header fields = {}, &block
      attrs = @subcomponents[:transmission_header].merge(fields)
      return nil if attrs.empty? && !block
      merged_fields = fields_for(self.class::TranmissionHeader).merge(attrs)
      @transmission_header ||= self.class::TranmissionHeader.new(merged_fields)
      @transmission_header.tap do 
        instance_eval(&block) if block
      end
    end
    
    def batch_count
      batches.length
    end
    
    def block_count
      ((file_entry_addenda_count + batch_count*2 + 2).to_f / BLOCKING_FACTOR).ceil
    end
    
    def file_entry_addenda_count
      batches.map{ |b| b.entry_addenda_count }.inject(&:+) || 0
    end
    
    def entry_hash
      batches.map(&:entry_hash).compact.inject(&:+)
    end
    
    def total_debit_amount
      batches.map(&:total_debit_amount).compact.inject(&:+)
    end
    
    def total_credit_amount
      batches.map(&:total_credit_amount).compact.inject(&:+)
    end
    
    def to_ach
      extra = block_count * BLOCKING_FACTOR - file_entry_addenda_count - batch_count*2  - 2
      tail = ([Tail.new] * extra).unshift(control)
      [transmission_header, header].compact + batches.map(&:to_ach).flatten + tail
    end
    
    def to_s!
      to_ach.map(&:to_s!).join("\r\n") + "\r\n"
    end
    
    def record_count
      2 + batches.length * 2 + file_entry_addenda_count
    end
    
    def write filename
      return false unless valid?
      ::File.open(filename, 'w') do |fh|
        fh.write(to_s!)
      end
    end
  end
end
