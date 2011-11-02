module ACH
  module File::Reader

    def self.from_string string
      to_ach string
    end

    def self.from_file filename
      read_file(filename) do |string|
        from_string string
      end
    end

    def self.parse string
      Parser.run(string)
    end

    def self.to_ach string
      header_row, batches_rows, control_row = parse(string)

      File.new.tap do |file|
        file.header = File::Header.from_str(header_row)

        batches_rows.each do |batch_params|
          file.batches << Batch.new.tap do |batch|
            batch.header = Batch::Header.from_str(batch_params[:header])
            batch.entries << Record::Entry.from_str(batch_params[:entry])
            batch.addenda Record::Addenda.from_str(batch_params[:addenda]).fields
            batch.control = Batch::Control.from_str(batch_params[:control])
          end
        end

        file.control = File::Control.from_str(control_row)
      end
    end

    def self.read_file filename, &block
      file = ::File.open filename, 'r'
      block.call(file.read)
    ensure
      file.close
    end

  end
end