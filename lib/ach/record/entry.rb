module ACH
  module Record
    # A subclass of ACH::Record::Base, an Entry appears in an ACH::Batch
    # component. It is the main record for representing a particular
    # transaction.
    #
    # == Fields
    #
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
    class Entry < Base
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
      
      defaults :record_type => BATCH_ENTRY_RECORD_TYPE,
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
end
