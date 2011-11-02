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

    def parse string
      @parser = Parser.new string
      @parser.run
    end

    protected

      def to_ach_file string
        header, batches, control = parse(string)
        ACH::File.new.tap do |file|
          apply_header! header, file
          batches.each { |batch| apply_batch! batch, file }
          apply_control! control, file
        end
      end

      def apply_header! header, file
        file.header do |h|
          header.fields.each_pair do |field_name, value|
            h.send field_name, value
          end
        end
      end

      def apply_batch! batch, file

      end

      def apply_control! control, file
        file.control = control
      end

      def read_file filename, &block
        file = ::File.open filename, 'r'
        block.call(file.read).tap do
          file.close
        end
      end

  end
end