module ACH
  # {ACH::File ACH::File} represents an ACH file. Every file have {ACH::File::Header header}
  # and {ACH::File::Control control} records and number of {ACH::Batch batches}.
  # {ACH::File::TransmissionHeader Transmission header} is optional.
  #
  # = Example:
  #
  #   # Inherit File to set default values
  #   class CustomAchFile < ACH::File
  #     immediate_dest        '123123123'
  #     immediate_dest_name   'COMMERCE BANK'
  #     immediate_origin      '123123123'
  #     immediate_origin_name 'MYCOMPANY'
  #   end
  #
  #   # Create a new instance
  #   ach_file = CustomAchFile.new do
  #     batch(:entry_class_code => "WEB", :company_entry_descr => "TV-TELCOM") do
  #       effective_date Time.now.strftime('%y%m%d')
  #       desc_date      Time.now.strftime('%b %d').upcase
  #       origin_dfi_id "00000000"
  #       entry :customer_name  => 'JOHN SMITH',
  #             :customer_acct  => '61242882282',
  #             :amount         => '2501',
  #             :routing_number => '010010101',
  #             :bank_account   => '103030030'
  #     end
  #   end
  #   
  #   # convert to string
  #   ach_file.to_s! # => returns string representation of file
  #
  #   # write to file
  #   ach_file.write('custom_ach.txt')
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
      merged_fields = fields_for(self.class::TransmissionHeader).merge(attrs)
      @transmission_header ||= self.class::TransmissionHeader.new(merged_fields)
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
      batch_sum_of(:entry_hash)
    end
    
    def total_debit_amount
      batch_sum_of(:total_debit_amount)
    end
    
    def total_credit_amount
      batch_sum_of(:total_credit_amount)
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

    def batch_sum_of(meth)
      batches.map(&meth).compact.inject(&:+)
    end
    private :batch_sum_of
  end
end
