module ACH
  # Represent Addenda Record
  class Addenda < Record
    fields :record_type,
           :addenda_type_code,
           :payment_related_info,
           :addenda_sequence_num,
           :entry_details_sequence_num

    defaults :record_type => 7
  end
end
