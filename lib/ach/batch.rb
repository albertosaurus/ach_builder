module ACH
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
      entries.select(&:debit?).map{ |e| e.amount.to_i }.compact.inject(&:+) || 0
    end
    
    def total_credit_amount
      entries.select(&:credit?).map{ |e| e.amount.to_i }.compact.inject(&:+) || 0
    end
    
    def to_ach
      [header] + entries + addendas + [control]
    end
    
    def before_header
      attributes[:service_class_code] ||= (has_debit? && has_credit? ? 200 : has_debit? ? 225 : 220)
    end
  end
end
