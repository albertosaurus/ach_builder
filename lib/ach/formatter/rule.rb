module ACH
  # Parses string representation of rule and converts it to proc.
  class Formatter::Rule
    RULE_PARSER_REGEX = /^(<-|->)(\d+)(-)?(\|\w+)?$/

    def initialize(rule)
      just, width, pad, transf = rule.match(RULE_PARSER_REGEX)[1..-1]
      @length    = width.to_i
      @padmethod = just == '<-' ? :ljust : :rjust
      @padstr    = @padmethod == :ljust ? ' ' : pad == '-' ? ' ' : '0'
      @transform = transf[1..-1] if transf
    end

    def to_proc
      lambda do |val|
        val = val.to_s[0..@length]
        (@transform ? val.send(@transform) : val).send(@padmethod, @length, @padstr)
      end
    end
  end
end
