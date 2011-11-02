module ACH
  module File::TransmissionHeader
    extend ActiveSupport::Concern

    class RedefinedTransmissionHeader < RuntimeError
      def initialize
        super "TransmissionHeader record may be defined only once"
      end
    end
    
    class EmptyTransmissionHeader < RuntimeError
      def initialize
        super "Transmission_header should declare it's fields"
      end
    end

    module ClassMethods
      def transmission_header &block
        raise RedefinedTransmissionHeader if have_transmission_header?
        klass = Class.new(Record::Dynamic, &block)
        raise EmptyTransmissionHeader.new if klass.fields.nil? || klass.fields.empty?
        const_set(:TransmissionHeader, klass)
        @have_transmission_header = true
      end
      
      def have_transmission_header?
        @have_transmission_header
      end
    end

    def have_transmission_header?
      self.class.have_transmission_header?
    end
    
    def transmission_header(fields = {}, &block)
      return nil unless have_transmission_header?
      merged_fields = fields_for(self.class::TransmissionHeader).merge(fields)
      @transmission_header ||= self.class::TransmissionHeader.new(merged_fields)
      @transmission_header.tap do |head|
        head.instance_eval(&block) if block
      end
    end
  end
end