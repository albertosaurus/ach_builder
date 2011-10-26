module ACH
  # Every field should be formatted with its own rule so Formatter take care about it.
  # Rules are defined in ACH::RULES constant.
  #
  # == Rule format:
  # Every rule can contain the next items:
  # * _justification_  - "<-" or "->".
  # * _width_          - a number of characters for a field.
  # * _padding_        - if "-" setted pads with spaces otherwise uses zeros.
  # * _transformation_ - allows to call method on a string. Pipe must precedes a method name. Foe example: "|upcase".
  # For real examples see RULES constants.
  #
  # == Usage example:
  #    ACH::Formatter.format(:customer_name, "LINUS TORVALDS")  # => "LINUS TORVALDS        "
  #    ACH::Formatter.format(:amount, 52)                       # => "0000000052"
  module Formatter
    extend self

    mattr_accessor :compiled_rules
    self.compiled_rules = {}
    
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

      # Addenda Record
      :addenda_type_code          => '->2',
      :payment_related_info       => '<-80',
      :addenda_sequence_num       => '->4',
      :entry_details_sequence_num => '->7'
    }
    
    def defined? field_name
      RULES.key?(field_name)
    end
    
    def define field, format
      RULES[field] = format
    end
    
    def method_missing meth, *args
      defined?(meth) ? format(meth, *args) : super
    end

    def format field_name, value
      rule_for_field(field_name).call(value)
    end
    
    def rule_for_field(field)
      compiled_rules[field] ||= Rule.new(RULES[field])
    end
    private :rule_for_field
  end
end
