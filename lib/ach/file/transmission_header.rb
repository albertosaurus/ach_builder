module ACH
  class File::TranmissionHeader < Record
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
