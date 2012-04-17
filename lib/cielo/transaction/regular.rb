module Cielo
  class Transaction::Regular < Cielo::Transaction::Base
    PRODUTOS = {:credito_vista => 1, :credito_parcelado_loja => 2, :credito_parcelado_adm => 3, :debito => "A"}
    AUTORIZACOES = [0,1,2,3]
    
    attribute :url_retorno, type: String, default: lambda { Cielo.return_path }
    attribute :bin, type: Integer
    attribute :enviar_portador, type: Boolean, default: false
    validates :url_retorno, :presence => true, :length => {:maximum => 1024}
    validates :autorizar, :inclusion => {:in => AUTORIZACOES}
    validates :forma_pagamento_produto, :inclusion => {:in => PRODUTOS.values}, :presence => true
    attribute :campo_livre, type: String
    
    def root_attributes
      %w(url_retorno autorizar capturar campo_livre bin)
    end
  end
end