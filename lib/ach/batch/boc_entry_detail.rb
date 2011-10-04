module ACH
  class BocEntryDetail < Record
    fields :record_type,
           :transaction_code,
           :receiving_dfi_id,
           :check_digit,
           :dfi_account_num,
           :amount,
           :check_serial_num,     
           :customer_name,        
           :discretionary_data,
           :addenda,
           :trace_num
  end
end
