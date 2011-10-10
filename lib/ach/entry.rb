module ACH
  # Entry is {ACH::Record record} which locates inside of {ACH::Batch batch} component.
  # == Fields:
  # * record_type
  # * transaction_code
  # * routing_number
  # * bank_account
  # * amount
  # * customer_acct
  # * customer_name
  # * transaction_type
  # * addenda
  # * bank_15
  class Entry < Record
    CREDIT_TRANSACTION_CODE_ENDING_DIGITS = ('0'..'4').to_a.freeze
    
    fields :record_type,
      :transaction_code,
      :routing_number,
      :bank_account,
      :amount,
      :customer_acct,
      :customer_name,
      :transaction_type,
      :addenda,
      :bank_15
    
    defaults :record_type => 6,
      :transaction_code   => 27,
      :transaction_type   => 'S',
      :customer_acct      => '',
      :addenda            => 0,
      :bank_15            => ''
    
    def debit?
      !credit?
    end
    
    def credit?
      CREDIT_TRANSACTION_CODE_ENDING_DIGITS.include? transaction_code.to_s[1..1]
    end
  end
end
