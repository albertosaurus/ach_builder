module ACH
  # File header record is the first {ACH::Record record} of every ACH file(in case when
  # {ACH::File::TransmissionHeader transmission header} is absent).
  # == Fields:
  # * record_type
  # * priority_code
  # * immediate_dest
  # * immediate_origin
  # * date
  # * time
  # * file_id_modifier
  # * record_size
  # * blocking_factor
  # * format_code
  # * immediate_dest_name
  # * immediate_origin_name
  # * reference_code
  class File::Header < Record
    fields :record_type,
      :priority_code,
      :immediate_dest,
      :immediate_origin,
      :date,
      :time,
      :file_id_modifier,
      :record_size,
      :blocking_factor,
      :format_code,
      :immediate_dest_name,
      :immediate_origin_name,
      :reference_code
    
    defaults :record_type => 1,
      :priority_code      => 1,
      :date               => lambda{ Time.now.strftime("%y%m%d") },
      :time               => lambda{ Time.now.strftime("%H%M") },
      :file_id_modifier   => 'A',
      :record_size        => RECORD_SIZE,
      :blocking_factor    => BLOCKING_FACTOR,
      :format_code        => FORMAT_CODE,
      :reference_code     => ''
  end
end
