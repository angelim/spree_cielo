module Cielo
  class Transaction::Direct < Cielo::Transaction::Base
    attribute :enviar_portador, type: Boolean, default: true
    validates :autorizar, :format => {:with => /3/}
      
    def root_attributes
      %w(autorizar capturar)
    end
  end
end