require 'active_support/concern'
require 'active_support/dependencies/autoload'
require 'active_support/inflector'
require 'active_support/ordered_hash'
require 'active_support/core_ext/hash/deep_merge'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/core_ext/class/attribute'

require "ach/version"

module ACH
  def self.to_const name
    [self, self::Record].detect{ |mod| mod.const_defined?(name) }.const_get(name)
  end
end

require 'ach/constants'
require 'ach/formatter'
require 'ach/formatter/rule'
require 'ach/validations'
require 'ach/component'
require 'ach/record'
require 'ach/batch'
require 'ach/file'
require 'ach/file/header'
require 'ach/file/control'
require 'ach/file/reader'
