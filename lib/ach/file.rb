module ACH
  class File < Component
    has_many :batches, lambda{ {:batch_number => batches.length + 1} }

    def transmission_header fields = {}, &block
      merged_fields = fields_for(self.class::TranmissionHeader).merge(@subcomponents[:transmission_header]).merge(fields)
      @transmission_header ||= self.class::TranmissionHeader.new(merged_fields)
      @transmission_header.tap do |th|
        th.instance_eval(&block) if block
      end
    end
    
    def batch_count
      batches.length
    end
    
    def block_count
      (file_entry_count.to_f / BLOCKING_FACTOR).ceil
    end
    
    def file_entry_count
      batches.map{ |b| b.entries.length }.inject(&:+) || 0
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
      extra = block_count * BLOCKING_FACTOR - file_entry_count
      tail = ([Tail.new] * extra).unshift(control)
      [transmission_header, header] + batches.map(&:to_ach).flatten + tail
    end
    
    def to_s!
      to_ach.map(&:to_s!).join("\r\n") + "\r\n"
    end
    
    def record_count
      2 + batches.length * 2 + file_entry_count
    end
    
    def write filename
      return false unless valid?
      ::File.open(filename, 'w') do |fh|
        fh.write(to_s!)
      end
    end
  end
end
