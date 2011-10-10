module ACH
  # Addenda is {ACH::Record record} which locates inside of {ACH::Batch batch} component.
  # == Fields:
  # * record_type
  # * addenda_type_code
  # * payment_related_info
  # * addenda_sequence_num
  # * entry_details_sequence_num
  class Addenda < Record
    fields :record_type,
           :addenda_type_code,
           :payment_related_info,
           :addenda_sequence_num,
           :entry_details_sequence_num

    defaults :record_type => 7
  end
end
