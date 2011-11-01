require 'singleton'
require 'active_support/core_ext/module/delegation'

module ACH
  class Reader
    include Singleton

    class << self
      delegate :from_string, :from_file, :to => :instance
    end

    def from_string string
      to_ach_file string
    end

    def from_file filename
      read_file(filename) do |string|
        from_string string
      end
    end

    def to_ach_file string
      reader = self
      klass  = ACH::File
      klass.new do |file|
        reader.parse_string_and_apply string, file
      end
    end

    def parse_string_and_apply string, file
      attributes, header_fields, batches = parse(string)
      p attributes
      p header_fields
      p batches
    end

    def parse string
      rows = string.clone.split("\n")
      [ extract_attributes!(rows), extract_header!(rows), extract_batches!(rows) ]
    end

    def extract_attributes! rows

    end

    def extract_header! rows
      header = ACH::File::Header.new
      rows.each_with_index do |row, i|
        if row[0..0].to_i == header.record_type
          header.from_str rows.delete(i)
        end
      end
    end

    def extract_batches! rows

    end

    def read_file filename, &block
      file = ::File.open filename, 'r'
      block.call(file.read).tap do
        file.close
      end
    end

  end
end