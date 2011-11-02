module ACH
  module Batch::Parser
    def parse enum
      loop do
        line = enum.next.chomp
        case line[0]
        when ?6 then entry(line)
        when ?7 then addenda(line)
        when ?8 then break control(line)
        end
      end
      self
    end
  end
end