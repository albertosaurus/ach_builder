module ACH
  # Hosts the most record classes available in ACH functionality. Records
  # not included in this module are ACH::File::Header, ACH::File::Control,
  # ACH::Batch::Header, ACH::Batch::Control
  module Record
    extend ActiveSupport::Autoload

    autoload :Addenda
    autoload :Base
    autoload :Dynamic
    autoload :Entry
    autoload :Tail
  end
end