module ACH
  module File::Builder

    def batch_count
      batches.length
    end
    
    def block_count
      ((file_entry_addenda_count + batch_count*2 + 2).to_f / Constants::BLOCKING_FACTOR).ceil
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
    
    def to_s!
      to_ach.map(&:to_s!).join(Constants::ROWS_DELIMITER)
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

    def to_ach
      head = [ header ]
      head.unshift(transmission_header) if have_transmission_header?
      head + batches.map(&:to_ach).flatten + [control] + tail
    end

    def tail
      [ Record::Tail.new ] * tails_count
    end

    def tails_count
      block_count * Constants::BLOCKING_FACTOR - file_entry_addenda_count - batch_count*2 - 2
    end

  end
end