module ACH
  class File::Reader::Parser

    attr_accessor :source, :header, :control, :current_batch
    attr_writer :batches

    def initialize string
      self.source = string
    end

    def self.run string
      new(string).run
    end

    def run
      detect_components
      [ header, batches, control ]
    end

    def batches
      @batches || []
    end

    def each_row &block
      rows.each do |row|
        block.call row[0..0].to_i, row
      end
    end
    private :each_row

    def rows
      @rows ||= source.split(Constants::ROWS_DELIMITER)
    end
    private :rows

    def detect_components
      self.batches = []

      each_row do |record_type, row|
        case record_type
          when Constants::FILE_HEADER_RECORD_TYPE
            self.header = row
          when Constants::BATCH_HEADER_RECORD_TYPE
            self.initialize_batch!
            self.current_batch[:header] = row
          when Constants::BATCH_ENTRY_RECORD_TYPE
            self.current_batch[:entry] = row
          when Constants::BATCH_ADDENDA_RECORD_TYPE
            self.current_batch[:addenda] = row
          when Constants::BATCH_CONTROL_RECORD_TYPE
            self.current_batch[:control] = row
            self.save_current_batch!
          when Constants::FILE_CONTROL_RECORD_TYPE
            self.control = row
        end
      end
    end
    private :detect_components

    def initialize_batch!
      self.current_batch = {}
    end

    def save_current_batch!
      self.batches << current_batch
    end

  end
end