module ACH
  module File::Parser
    def parse enum
      loop do
        line = enum.next.chomp
        case line[0]
        when ?1 then header(line)
        when ?5
          batch do
            extend ACH::Batch::Parser
            header line
            parse enum
          end
        when ?9 then break control(line)
        end
      end
      self
    end
  end
end