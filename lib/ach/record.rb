module ACH
  module Record
    extend ActiveSupport::Autoload

    autoload :Addenda
    autoload :Base
    autoload :Dynamic
    autoload :Entry
    autoload :Tail
  end
end