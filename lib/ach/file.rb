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
    class RedefinedTransmissionHeader < RuntimeError
      def initialize
        super "TransmissionHeader record may be defined only once"
      end
    end
    
    class EmptyTransmissionHeader < RuntimeError
      def initialize
        super "Transmission_header should declare it's fields"
      end
    end
    
    has_many :batches, :proc_defaults => lambda{ {:batch_number => batches.length + 1} }

    def self.transmission_header &block
      raise RedefinedTransmissionHeader if have_transmission_header?
      klass = Class.new(Record::Dynamic, &block)
      raise EmptyTransmissionHeader.new if klass.fields.nil? || klass.fields.empty?
      const_set(:TransmissionHeader, klass)
      @have_transmission_header = true
    end

    def self.read filename
      Reader.from_file filename
    end
    
    def self.have_transmission_header?
      @have_transmission_header
    end
    
    def have_transmission_header?
      self.class.have_transmission_header?
    end
    
    def transmission_header(fields = {}, &block)
      return nil unless have_transmission_header?
      merged_fields = fields_for(self.class::TransmissionHeader).merge(fields)
      @transmission_header ||= self.class::TransmissionHeader.new(merged_fields)
      @transmission_header.tap do |head|
        head.instance_eval(&block) if block
      end
    end
    
    def batch_count
      batches.length
    end
    
    def block_count
      ((file_entry_addenda_count + batch_count*2 + 2).to_f / BLOCKING_FACTOR).ceil
    end
    
    def file_entry_addenda_count
      batches.map{ |batch| batch.entry_addenda_count }.inject(&:+) || 0
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
      head = [ header ]
      head.unshift(transmission_header) if have_transmission_header?
      head + batches.map(&:to_ach).flatten + [control] + tail
    end
    
    def to_s!
      to_ach.map(&:to_s!).join("\r\n") + "\r\n"
    end
    
    def record_count
      2 + batch_count * 2 + file_entry_addenda_count
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

    def tail
      [ Tail.new ] * tails_count
    end

    def tails_count
      block_count * BLOCKING_FACTOR - file_entry_addenda_count - batch_count*2 - 2
    end

  end
end
