module ACH
  # Represents a Proc built up from a string shortcut defined by Formatter::RULES
  class Formatter::Rule < Proc
    RULE_PARSER_REGEX = /^(<-|->)(\d+)(-)?(\|\w+)?$/

    def self.new(rule)
      just, width, pad, transf = rule_params rule
      length    = width.to_i
      padmethod = just == '<-' ? :ljust : :rjust
      padstr    = padmethod == :ljust ? ' ' : pad == '-' ? ' ' : '0'
      transform = transf[1..-1] if transf
      super(&Proc.new do |val|
        val = val.to_s
        (transform ? val.send(transform) : val).send(padmethod, length, padstr)[-length..-1]
      end)
    end

    def self.rule_params rule
      rule.match(RULE_PARSER_REGEX)[1..-1]
    end
  end
end
