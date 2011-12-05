module ACH
  # This module hosts all the methods required for building string representation of a
  # particular instance of an ACH batch. For the most, defines helper methods used for
  # building ACH lines. Included by the ACH::File.
  module Batch::Builder
    # Returns +true+ if any of internal ACH entries has 'credit' transaction code
    def has_credit?
      entries.any?(&:credit?)
    end

    # Returns +true+ if any of internal ACH entries has 'debit' transaction code
    def has_debit?
      entries.any?(&:debit?)
    end

    # Returns total amount of entry and addenda records within batch
    def entry_addenda_count
      entries.size + addendas.values.flatten.size
    end

    # Returns 'hashed' representation of all entries within batch. See NACHA
    # documentation for more details on entry hash
    def entry_hash
      entries.map{ |entry| entry.routing_number.to_i / 10 }.compact.inject(&:+)
    end

    # Returns total amount of all 'debit' entries within a batch
    def total_debit_amount
      amount_sum_for(:debit?)
    end

    # Returns total amount of all 'credit' entries within a batch
    def total_credit_amount
      amount_sum_for(:credit?)
    end

    # Returns ACH record objects that represent the batch
    def to_ach
      [header] + fetch_entries + [control]
    end

    # Helper method executed just before building a header record for the batch
    def before_header
      attributes[:service_class_code] ||= (has_debit? && has_credit? ? 200 : has_debit? ? 225 : 220)
    end
    private :before_header

    # Helper method, returns total amount of all entries within a batch, filtered by +meth+
    def amount_sum_for(meth)
      entries.select(&meth).map{ |entry| entry.amount.to_i }.compact.inject(&:+) || 0
    end
    private :amount_sum_for

    # Fetches all internal records (entries and addendas) in right order, i.e. addenda records
    # should be positioned right after corresponding entry records.
    def fetch_entries
      entries.inject([]){ |all, entry| all << entry << addendas[entry] }.flatten.compact
    end
    private :fetch_entries
  end
end