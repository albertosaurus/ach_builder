module ACH
  class Builder
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
        hash_or_value = args.first
        if hash_or_value.is_a? Hash
          @hash[meth.to_sym] = BlankStruct.new(hash_or_value)
        else
          @hash[meth.to_sym] = hash_or_value
        end
        @hash[meth.to_sym] = BlankStruct.new.tap{|bs| bs.instance_exec(&block)} if block_given?
      end
    end
  end
end
