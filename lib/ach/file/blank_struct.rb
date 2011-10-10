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
    instance_methods.each { |meth| undef_method meth unless meth =~ /^(__send__|__id__|instance_exec|is_a\?|tap|class)$/ }

    def initialize(hash = {})
      @hash = hash
    end

    def to_hash
      return @hash if @hash.empty?
      @hash.inject({}) do |hash, (key, val)|
        hash[key] = (val.is_a?(File::BlankStruct) ? val.to_hash : val)
        hash
      end
    end

    def method_missing(meth, *args, &block)
      attr, value = meth.to_sym, args.first
      if block_given?
        @hash[attr] = File::BlankStruct.new.tap{|bs| bs.instance_exec(&block)} 
      else
        @hash[attr] = value.is_a?(Hash) ? File::BlankStruct.new(value) : value
      end
    end

  end
end
