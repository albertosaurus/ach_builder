module ACH
  # This module hosts all the methods required for building string representation of an ACH file,
  # and writing it to an actual file in the filesystem. Included by the ACH::File.
  module File::Builder
    # Returns amount of +batches+ in file
    def batch_count
      batches.length
    end

    # Returns amount of blocks, used in count. This amount is based on <tt>blocking factor</tt>,
    # which is usually equals to 10, and on overall amount of records in a file. Return value
    # represents the least amount of blocks taken by records in file.
    def block_count
      (record_count.to_f / Constants::BLOCKING_FACTOR).ceil
    end

    # Returns total amount of +entry+ and +addenda+ records of all batches within file.
    def file_entry_addenda_count
      batches.map{ |batch| batch.entry_addenda_count }.inject(&:+) || 0
    end

    # Returns sum of +entry_hash+ values of all batches within self
    def entry_hash
      batch_sum_of(:entry_hash)
    end

    # Returns sum of +total_debit_amount+ values of all batches within self
    def total_debit_amount
      batch_sum_of(:total_debit_amount)
    end

    # Returns sum of +total_credit_amount+ values of all batches within self
    def total_credit_amount
      batch_sum_of(:total_credit_amount)
    end

    # Returns complete string representation of a ACH file by converting each interval record
    # to a string and joining the result by <tt>Constants::ROWS_DELIMITER</tt>
    def to_s!
      to_ach.map(&:to_s!).join(Constants::ROWS_DELIMITER)
    end

    # Returns total amount of records hosted by a file.
    def record_count
      2 + batch_count * 2 + file_entry_addenda_count
    end

    # Writes string representation of self to passed +filename+
    def write(filename)
      return false unless valid?
      ::File.open(filename, 'w') do |fh|
        fh.write(to_s!)
      end
    end

    # Helper method for calculating different properties of batches within file
    def batch_sum_of(meth)
      batches.map(&meth).compact.inject(&:+)
    end
    private :batch_sum_of

    # Returns well-fetched array of all ACH records in the file, appending proper
    # amount, based on number of blocks, of tail records to it.
    def to_ach
      head = [ header ]
      head.unshift(transmission_header) if have_transmission_header?
      head + batches.map(&:to_ach).flatten + [control] + tail
    end

    # Returns array of ACH::Record::Tail records, based on +tails_count+
    def tail
      [ Record::Tail.new ] * tails_count
    end

    # Returns amount of ACH::Record::Tail records, required to append to
    # string representation of a file to match proper amount of blocks.
    def tails_count
      block_count * Constants::BLOCKING_FACTOR - record_count
    end
  end
end