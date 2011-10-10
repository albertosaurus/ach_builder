module ACH
  # Every {ACH::File ACH file} ends with file control record.
  # == Fields:
  # * record_type
  # * batch_count
  # * block_count
  # * file_entry_addenda_count
  # * entry_hash
  # * total_debit_amount
  # * total_credit_amount
  # * bank_39
  class File::Control < Record
    fields :record_type,
      :batch_count,
      :block_count,
      :file_entry_addenda_count,
      :entry_hash,
      :total_debit_amount,
      :total_credit_amount,
      :bank_39
    
    defaults :record_type => 9,
      :bank_39            => ''
  end
end
