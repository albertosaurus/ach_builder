module ACH
  # == Usage
  #   class CustomAchBuilder < ACH::Builder
  #     default_options :file do
  #       company_name "MY COMPANY"
  #       default_options :batch do
  #         entry(:customer => "JOHN SMITH")
  #       end
  #     end
  #   end
  #
  #   CustomAchBuilder.build do
  #     # Same what you do with ACH::File.new
  #   end
  class Builder
    def self.default_options(component = :file, attrs = {}, &block)
      bs = BlankStruct.new
      bs.instance_exec(&block) if block
      @opts_hash = attrs.deep_merge(bs.to_hash)
    end

    def self.opts_hash
      @opts_hash|| {}
    end

    def self.build(fields = {}, &block)
      merged_fields = self.opts_hash.deep_merge(fields)
      ACH::File.new(merged_fields)
    end
  end
end
