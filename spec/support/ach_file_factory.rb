class ACH::FileFactory

  def self.sample_file(custom_attrs = {})
    attrs = {:company_id => '11-11111', :company_name => 'MY COMPANY'}
    attrs.merge!(custom_attrs)

    ACH::File.new(attrs) do
      immediate_dest '123123123'
      immediate_dest_name 'COMMERCE BANK'
      immediate_origin '123123123'
      immediate_origin_name 'MYCOMPANY'
      
      ['WEB', 'TEL'].each do |code|
        batch(:entry_class_code => code, :company_entry_descr => 'TV-TELCOM') do
          effective_date Time.now.strftime('%y%m%d')
          origin_dfi_id "00000000"
          entry :customer_name => 'JOHN SMITH',
            :customer_acct     => '61242882282',
            :amount            => '2501',
            :routing_number    => '010010101',
            :bank_account      => '103030030'
        end
      end
    end
  end


  def self.with_transmission_header(custom_attrs)
    attrs = {:remote_id => 'ABCDEFGH', :application_id => '12345678'}.merge(custom_attrs)
    sample_file(:transmission_header => attrs)
  end

end