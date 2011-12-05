require 'active_support/concern'
require 'active_support/dependencies/autoload'
require 'active_support/inflector'
require 'active_support/ordered_hash'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/core_ext/class/attribute'

require "ach/version"

module ACH
  extend ActiveSupport::Autoload

  autoload :Constants
  autoload :Formatter
  autoload :Validations
  autoload :Component
  autoload :Record
  autoload :Batch
  autoload :File

  def self.to_const(name)
    [self, self::Record].detect{ |mod| mod.const_defined?(name) }.const_get(name)
  end
end
