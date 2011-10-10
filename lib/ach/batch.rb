module ACH
  # Batch is kind of {ACH::Component} which has number of
  # {ACH::Entry entries} and {ACH::Addenda addendas}.
  class Batch < Component
    has_many :entries
    has_many :addendas
    
    def has_credit?
      entries.any?(&:credit?)
    end
    
    def has_debit?
      entries.any?(&:debit?)
    end
    
    def entry_addenda_count
      entries.size + addendas.size
    end
    
    def entry_hash
      entries.map{ |e| e.routing_number.to_i / 10 }.compact.inject(&:+)
    end
    
    def total_debit_amount
      amount_sum_for(:debit?)
    end
    
    def total_credit_amount
      amount_sum_for(:credit?)
    end
    
    def to_ach
      [header] + entries + addendas + [control]
    end
    
    def before_header
      attributes[:service_class_code] ||= (has_debit? && has_credit? ? 200 : has_debit? ? 225 : 220)
    end

    def amount_sum_for(meth)
      entries.select(&meth).map{ |e| e.amount.to_i }.compact.inject(&:+) || 0
    end
    private :amount_sum_for
  end
end
