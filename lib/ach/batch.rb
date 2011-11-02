module ACH
  # Batch is kind of {ACH::Component} which has number of
  # {ACH::Entry entries} and {ACH::Addenda addendas}.
  class Batch < Component
    autoload :Builder
    autoload :Control
    autoload :Header

    has_many :entries
    has_many :addendas, :linked_to => :entries
  end
end
