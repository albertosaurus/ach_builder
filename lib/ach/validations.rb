module ACH
  module Validations
    def valid?
      reset_errors!
      is_a?(Component) ? valid_component? : valid_record?
      errors.empty?
    end
    
    def valid_component?
      counts = Hash.new(0)
      to_ach.each do |record|
        unless record.valid?
          klass = record.class
          errors["#{klass}##{counts[klass] += 1}"] = record.errors
        end
      end
    end
    private :valid_component?
    
    def valid_record?
      self.class.fields.each do |field|
        errors[field] = "is required" unless fields[field]
      end
    end
    private :valid_record?
    
    def errors
      @errors || reset_errors!
    end
    
    def reset_errors!
      @errors = ActiveSupport::OrderedHash.new
    end
    private :reset_errors!
  end
end
