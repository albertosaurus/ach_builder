module ACH
  module Constants
    # The length of each record in characters.
    RECORD_SIZE     = 94
    # The file's total record count must be a multiple of this number. The
    # file must be padded with blocking file control records (consisting
    # entirely of 9s) to satisfy this condition.
    BLOCKING_FACTOR = 10
    # Always "1".
    FORMAT_CODE     = 1
    # This character must be used to delimit each row.
    ROWS_DELIMITER  = "\n"

    FILE_HEADER_RECORD_TYPE   = 1
    FILE_CONTROL_RECORD_TYPE  = 9
    BATCH_HEADER_RECORD_TYPE  = 5
    BATCH_ENTRY_RECORD_TYPE   = 6
    BATCH_ADDENDA_RECORD_TYPE = 7
    BATCH_CONTROL_RECORD_TYPE = 8
  end
end