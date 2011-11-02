module ACH
  class Reader::Parser

    attr_accessor :source

    def initialize string
      self.source = string
    end

    def run
      [ header, batch, control ]
    end

    def control
      ACH::File::Control.from_str(detect_control_row)
    end

    def detect_control_row
      each_row do |record_type, row|
        return row if file_control?(record_type)
      end
    end

    def header
      ACH::File::Header.from_str(detect_header_row)
    end

    def detect_header_row
      each_row do |record_type, row|
        return row if file_header? record_type
      end
    end

    def batch
      detect_data_rows.map do |data_entry|
        ACH::Batch.new.tap do |batch|
          batch.header  ACH::Batch::Header.from_str(data_entry[:header]).fields
          batch.entry   ACH::Entry.from_str(data_entry[:entry]).fields
          batch.addenda ACH::Addenda.from_str(data_entry[:addenda]).fields
          batch.control = ACH::Batch::Control.from_str data_entry[:control]
        end
      end
    end

    def detect_data_rows
      [].tap do |data_entries|
        rows = []

        each_row do |record_type, row|
          if file_batch? record_type
            rows << row
          else
            data_entry = detect_data_entry(rows)
            data_entries << data_entry unless data_entry.empty?
            rows = []
          end
        end
      end
    end

    def detect_data_entry rows
      {}.tap do |b|
        each_row(rows) do |record_type, row|
          case
            when file_batch_header?(record_type)
              b[:header] = row
            when file_batch_entry?(record_type)
              b[:entry] = row
            when file_batch_addenda?(record_type)
              b[:addenda] = row
            when file_batch_control?(record_type)
              b[:control] = row
          end
        end
      end
    end

    protected

      def each_row rows = self.rows, &block
        rows.each do |row|
          block.call row[0..0].to_i, row
        end
      end

      def rows
        @rows ||= source.split("\n")
      end

      def file_control? type
        type == 9
      end

      def file_header? type
        type == ACH::File::Header.new.record_type
      end

      def file_batch_header? type
        type == ACH::Batch::Header.new.record_type
      end

      def file_batch? type
        file_batch_header?(type) || file_batch_addenda?(type) || file_batch_entry?(type) || file_batch_control?(type)
      end

      def file_batch_addenda? type
        type == ACH::Addenda.new.record_type
      end

      def file_batch_entry? type
        type == batch_entry_record_type
      end

      def file_batch_control? type
        type == ACH::Batch::Control.new.record_type
      end

      def batch_header_record_type
        @batch_header_record_type ||= ACH::Batch::Header.new.record_type
      end

      def batch_entry_record_type
        @batch_entry_record_type ||= ACH::Entry.new.record_type
      end

  end
end