module Cielo
  class Transaction::Direct < Cielo::Transaction::Base
    PRODUTOS = {:credito_vista => 1, :credito_parcelado_loja => 2, :credito_parcelado_adm => 3}
    attribute :enviar_portador, type: Boolean, default: true
    validates :autorizar, :format => {:with => /3/}
    validates :forma_pagamento_produto, :inclusion => {:in => PRODUTOS.values}, :presence => true
      
    def root_attributes
      %w(autorizar capturar)
    end
  end
end