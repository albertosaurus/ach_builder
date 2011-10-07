module ACH
  class File
    # BlankStruct is used to build hash using blocks.
    # == Example:
    #   bs = BlankStruct.new(:first_level => 1)
    #   bs.second_level do
    #     foo "foo value"
    #     bar "bar value"
    #   end
    #   bs.to_hash # => {:first_level=>1, :second_level=>{:bar=>"bar value", :foo=>"foo value"}}
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
