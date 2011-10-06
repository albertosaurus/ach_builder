module ACH
  module Formatter
    extend self
    
    RULES = {
      :customer_name            => '<-22',
      :customer_acct            => '<-15',
      :amount                   => '->10',
      :bank_2                   => '<-2',
      :transaction_type         => '<-2',
      :bank_15                  => '<-15',
      :addenda                  => '<-1',
      :trace_num                => '<-15',
      :transaction_code         => '<-2',
      :record_type              => '<-1',
      :bank_account             => '<-17',
      :routing_number           => '->9',
      :priority_code            => '->2',
      :immediate_dest           => '->10-',
      :immediate_origin         => '->10-',
      :date                     => '<-6',
      :time                     => '<-4',
      :file_id_modifier         => '<-1|upcase',
      :record_size              => '->3',
      :blocking_factor          => '->2',
      :format_code              => '<-1',
      :immediate_dest_name      => '<-23',
      :immediate_origin_name    => '<-23',
      :reference_code           => '<-8',
      :service_class_code       => '<-3',
      :company_name             => '<-16', # aka Individual Name
      :company_note_data        => '<-20',
      :company_id               => '<-10',
      :entry_class_code         => '<-3',
      :company_entry_descr      => '<-10',
      :effective_date           => '<-6',
      :settlement_date          => '<-3',
      :origin_status_code       => '<-1',
      :origin_dfi_id            => '<-8',
      :batch_number             => '->7',
      :entry_addenda_count      => '->6',
      :entry_hash               => '->10',
      :total_debit_amount       => '->12',
      :total_credit_amount      => '->12',
      :authen_code              => '<-19',
      :bank_6                   => '<-6',
      :batch_count              => '->6',
      :block_count              => '->6',
      :file_entry_addenda_count => '->8',
      :bank_39                  => '<-39',
      :nines                    => '<-94',

      # Batch header
      :desc_date                => '<-6-', # company descriptive date

      # Transmission Header
      :request_type             => '<-9-',
      :remote_id                => '<-8-',
      :blank                    => '<-1-',
      :batch_id_parameter       => '<-4-',
      :starting_single_quote    => '<-1' ,
      :file_type                => '<-6-',
      :application_id           => '->8' ,
      :ending_single_quote      => '<-1' ,

      # Addenda Record
      :addenda_type_code          => '->2' ,
      :payment_related_info       => '<-80',
      :addenda_sequence_num       => '->4' ,
      :entry_details_sequence_num => '->7'
    }.freeze
    
    RULE_PARSER_REGEX = /^(<-|->)(\d+)(-)?(\|\w+)?$/
    
    @@compiled_rules = {}
    
    def format field_name, value
      compile_rule(field_name) unless @@compiled_rules.key?(field_name)
      @@compiled_rules[field_name].call(value)
    end
    
    def method_missing meth, *args
      if RULES.key? meth
        format meth, *args
      else
        super
      end
    end
    
    def compile_rule field_name
      just, width, pad, transf = RULES[field_name].match(RULE_PARSER_REGEX)[1..-1]
      padmethod = just == '<-' ? :ljust : :rjust
      length = width.to_i
      padstr = padmethod == :ljust ? ' ' : pad == '-' ? ' ' : '0'
      transform = transf[1..-1] if transf
      @@compiled_rules[field_name] = lambda{ |val|
        val = val.to_s[0..length]
        (transform ? val.send(transform) : val).send(padmethod, length, padstr)
      }
    end
    private :compile_rule
  end
end
