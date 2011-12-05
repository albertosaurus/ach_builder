module ACH
  # The main purpose of +Reader+ class is to build a corresponding <tt>ACH::File</tt>
  # object from a given set of data. Takes +enum+ object for constructor, which
  # represents a sequence of ACH lines (strings). This enum object may be a file
  # handler, or an array, or any other object that responds to +each+ method.
  class File::Reader
    include Constants

    def initialize(enum)
      @enum = enum
    end

    def to_ach
      header_line, batch_lines, control_line = ach_data

      File.new do
        build_header header_line

        batch_lines.each do |batch_data|
          batch do
            build_header batch_data[:header]

            batch_data[:entries].each do |entry_line|
              build_entry entry_line

              if batch_data[:addendas].key?(entry_line)
                batch_data[:addendas][entry_line].each do |addenda_line|
                  build_addenda addenda_line
                end
              end
            end

            build_control batch_data[:control]
          end
        end

        build_control control_line
      end
    end

    def ach_data
      process! unless processed?

      return @header, batches, @control
    end
    private :ach_data

    def process!
      each_line do |record_type, line|
        case record_type
        when FILE_HEADER_RECORD_TYPE
          @header = line
        when BATCH_HEADER_RECORD_TYPE
          initialize_batch!
          current_batch[:header] = line
        when BATCH_ENTRY_RECORD_TYPE
          current_batch[:entries] << line
        when BATCH_ADDENDA_RECORD_TYPE
          (current_batch[:addendas][current_entry] ||= []) << line
        when BATCH_CONTROL_RECORD_TYPE
          current_batch[:control] = line
        when FILE_CONTROL_RECORD_TYPE
          @control = line
        end
      end
      @processed = true
    end
    private :process!

    def processed?
      !!@processed
    end
    private :processed?

    def each_line
      @enum.each do |line|
        yield line[0..0].to_i, line.chomp
      end
    end
    private :each_line

    def batches
      @batches ||= []
    end
    private :batches

    def initialize_batch!
      batches << {:entries => [], :addendas => {}}
    end
    private :initialize_batch!

    def current_batch
      batches.last
    end
    private :current_batch

    def current_entry
      current_batch[:entries].last
    end
    private :current_entry
  end
end