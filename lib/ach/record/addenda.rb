module ACH
  module Record
    # Addenda is ACH::Record::Base record which is located inside of ACH::Batch component.
    # Addenda records should be preceded by ACH::Record::Entry entry records
    #
    # == Fields
    #
    # * record_type
    # * addenda_type_code
    # * payment_related_info
    # * addenda_sequence_num
    # * entry_details_sequence_num
    class Addenda < Base
      fields :record_type,
        :addenda_type_code,
        :payment_related_info,
        :addenda_sequence_num,
        :entry_details_sequence_num

      defaults :record_type => BATCH_ADDENDA_RECORD_TYPE,
        :addenda_type_code => 5
    end
  end
end
