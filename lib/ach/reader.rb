require 'singleton'

module ACH
  module Reader

    def self.from_string string
      to_ach_file string
    end

    def self.from_file filename
      read_file(filename) do |string|
        from_string string
      end
    end

    def self.parse string
      @parser = Parser.new string
      @parser.run
    end

    def self.to_ach_file string
      header, batches, control = parse(string)
      ACH::File.new.tap do |file|
        apply_header! header, file
        batches.each { |batch| apply_batch! batch, file }
        apply_control! control, file
      end
    end

    def self.apply_header! header, file
      file.header do |h|
        header.fields.each_pair do |field_name, value|
          h.send field_name, value
        end
      end
    end

    def self.apply_batch! batch, file
    end

    def self.apply_control! control, file
      file.control = control
    end

    def self.read_file filename, &block
      file = ::File.open filename, 'r'
      block.call(file.read)
    ensure
      file.close
    end

  end
end