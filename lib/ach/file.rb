module ACH
  # {ACH::File ACH::File} represents an ACH file. Every file have {ACH::File::Header header}
  # and {ACH::File::Control control} records and number of {ACH::Batch batches}.
  # {ACH::File::TransmissionHeader Transmission header} is optional.
  #
  # = Example:
  #
  #   # Inherit File to set default values
  #   class CustomAchFile < ACH::File
  #     immediate_dest        '123123123'
  #     immediate_dest_name   'COMMERCE BANK'
  #     immediate_origin      '123123123'
  #     immediate_origin_name 'MYCOMPANY'
  #   end
  #
  #   # Create a new instance
  #   ach_file = CustomAchFile.new do
  #     batch(:entry_class_code => "WEB", :company_entry_descr => "TV-TELCOM") do
  #       effective_date Time.now.strftime('%y%m%d')
  #       desc_date      Time.now.strftime('%b %d').upcase
  #       origin_dfi_id "00000000"
  #       entry :customer_name  => 'JOHN SMITH',
  #             :customer_acct  => '61242882282',
  #             :amount         => '2501',
  #             :routing_number => '010010101',
  #             :bank_account   => '103030030'
  #     end
  #   end
  #   
  #   # convert to string
  #   ach_file.to_s! # => returns string representation of file
  #
  #   # write to file
  #   ach_file.write('custom_ach.txt')
  class File < Component
    has_many :batches, :proc_defaults => lambda{ {:batch_number => batches.length + 1} }
  end
end
