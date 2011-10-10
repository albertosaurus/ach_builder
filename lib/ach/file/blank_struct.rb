module ACH
  # BlankStruct is used to build hash using blocks.
  # == Example:
  #   bs = BlankStruct.new(:first_level => 1)
  #   bs.second_level do
  #     foo "foo value"
  #     bar "bar value"
  #   end
  #   bs.to_hash # => {:first_level=>1, :second_level=>{:bar=>"bar value", :foo=>"foo value"}}
  class File::BlankStruct
    instance_methods.each { |m| undef_method m unless m =~ /^(__send__|__id__|instance_exec|is_a\?|tap|class)$/ }

    def initialize(hash = {})
      @hash = hash
    end

    def to_hash
      return @hash if @hash.empty?
      @hash.inject({}){ |h,(k,v)| h[k] = (v.is_a?(self.class) ? v.to_hash : v) ; h}
    end

    def method_missing(meth, *args, &block)
      attr, value = meth.to_sym, args.first
      if block_given?
        @hash[attr] = self.class.new.tap{|bs| bs.instance_exec(&block)} 
      else
        @hash[attr] = value.is_a?(Hash) ? self.class.new(value) : value
      end
    end

  end
end
