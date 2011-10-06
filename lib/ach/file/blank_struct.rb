module ACH
  class File
    class BlankStruct
      instance_methods.each { |m| undef_method m unless m =~ /^(__send__|__id__|instance_exec|is_a\?|tap)$/ }

      def initialize(hash = {})
        @hash = hash
      end

      def to_hash
        return @hash if @hash.empty?
        @hash.inject({}){ |h,(k,v)| h[k] = (v.is_a?(BlankStruct) ? v.to_hash : v) ; h}
      end

      def method_missing(meth, *args, &block)
        attr, value = meth.to_sym, args.first
        if block_given?
          @hash[attr] = BlankStruct.new.tap{|bs| bs.instance_exec(&block)} 
        else
          @hash[attr] = value.is_a?(Hash) ? BlankStruct.new(value) : value
        end
      end

    end
  end
end
