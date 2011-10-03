require 'active_support/inflector'
require 'active_support/ordered_hash'

require "ach/version"

require 'ach/constants'
require 'ach/formatter'
require 'ach/validations'
require 'ach/component'
require 'ach/record'
require 'ach/entry'
require 'ach/tail'
require 'ach/batch'
require 'ach/batch/header'
require 'ach/batch/control'
require 'ach/file'
require 'ach/file/transmission_header'
require 'ach/file/header'
require 'ach/file/control'

module ACH
  def self.sample_file
    File.new(:company_id => '11-11111', :company_name => 'MY COMPANY') do
      transmission_header(:remote_id => 'ABCDEFGH', :application_id => '12345678')
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
end
