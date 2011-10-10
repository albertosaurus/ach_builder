module ACH
  # Transmission header is optional and locates at the top of file before
  # {ACH::File::Header file header}. It's the only record which length is less 
  # than 94 characters.
  # == Fields:
  # * request_type,
  # * remote_id,
  # * blank,
  # * batch_id_parameter,
  # * starting_single_quote,
  # * file_type,
  # * application_id,
  # * ending_single_quote
  class File::TransmissionHeader < Record
    fields :request_type,
           :remote_id,
           :blank,
           :batch_id_parameter,
           :starting_single_quote,
           :file_type,
           :application_id,
           :ending_single_quote

    defaults :request_type          => '$$ADD ID=',
             :blank                 => ' ',
             :batch_id_parameter    => 'BID=',
             :starting_single_quote => "'",
             :file_type             => 'NWFACH',
             :ending_single_quote   => "'"
  end
end
