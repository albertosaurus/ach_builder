module ACH
  class File::Reader::Parser

    attr_accessor :source, :header, :control

    def initialize(string)
      self.source = string
    end

    def self.run(string)
      new(string).run
    end

    def run
      detect_components
      [ header, batches, control ]
    end

    def batches
      @batches || []
    end

    def each_row(&block)
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
      each_row do |record_type, row|
        case record_type
          when Constants::FILE_HEADER_RECORD_TYPE
            self.header = row
          when Constants::BATCH_HEADER_RECORD_TYPE
            initialize_batch!
            current_batch[:header] = row
          when Constants::BATCH_ENTRY_RECORD_TYPE
            current_batch[:entry] = row
          when Constants::BATCH_ADDENDA_RECORD_TYPE
            (current_batch[:addendas] ||= []) << row
          when Constants::BATCH_CONTROL_RECORD_TYPE
            current_batch[:control] = row
          when Constants::FILE_CONTROL_RECORD_TYPE
            self.control = row
        end
      end
    end
    private :detect_components

    def batches
      @batches ||= []
    end
    private :batches

    def initialize_batch!
      batches << {}
    end
    private :initialize_batch!

    def current_batch
      batches.last
    end
    private :current_batch
  end
end