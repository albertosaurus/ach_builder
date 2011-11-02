module ACH
  module Record
    class Dynamic < Base
      class DuplicateFormatError < ArgumentError
        def initialize field_name
          super "Rule #{field_name} has already been defined"
        end
      end
      
      class UndefinedFormatError < ArgumentError
        def initialize field_name
          super "Unknown field #{field_name} should be supplied by format"
        end
      end
      
      def self.method_missing field, *args
        format, default = args.first.is_a?(Hash) ? args.first.first : args
        unless format =~ Formatter::Rule::RULE_PARSER_REGEX
          default, format = format, nil
        end
        
        unless Formatter.defined? field
          raise UndefinedFormatError.new(field) if format.nil?
          Formatter.define field, format
        else
          raise DuplicateFormatError.new(field) if format
        end
        define_field_methods(field)
        (@fields ||= []) << field
        (@defaults ||= {})[field] = default if default
      end
    end
  end
end