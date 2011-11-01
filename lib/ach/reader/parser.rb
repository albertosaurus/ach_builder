module ACH
  class Reader::Parser

    attr_accessor :source

    def initialize string
      self.source = string
    end

    def rows
      @rows ||= source.split("\n")
    end

    def run
      [ detect_header, detect_batches, detect_control ]
    end

    def parse_string_and_apply string, file
      header, batches, control = parse(string)
      ACH::File::Header.from_str header
    end

    def detect_control
      each_row do |record_type, row|
        if file_control? record_type
          return row
        end
      end
    end

    def detect_header
      each_row do |record_type, row|
        if file_header? record_type
          return row
        end
      end
    end

    def detect_batches
      [].tap do |batches|
        each_row do |record_type, row|
          if file_batch_header? record_type
            batches << row
          end
        end
      end
    end

    def each_row &block
      rows.each do |row|
        block.call row[0..0].to_i, row
      end
    end

    def file_control? type
      type == 9
    end

    def file_header? type
      header = ACH::File::Header.new
      type == header.record_type
    end

    def file_batch_header? type
      batch_header = ACH::Batch::Header.new
      type == batch_header.record_type
    end

  end
end