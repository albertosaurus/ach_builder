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
      @parser = ACH::Reader::Parser.new string
      @parser.run
    end

    protected

      def to_ach_file string
        reader = self
        ACH::File.new do
          reader.parse string
        end
      end

      def read_file filename, &block
        file = ::File.open filename, 'r'
        block.call(file.read).tap do
          file.close
        end
      end

  end
end