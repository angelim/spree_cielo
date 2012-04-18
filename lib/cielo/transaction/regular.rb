module Cielo
  class Transaction::Regular < Cielo::Transaction::Base
    AUTORIZACOES = [0,1,2,3]
    
    attribute :url_retorno, type: String, default: lambda { Cielo.return_path }
    attribute :bin, type: Integer
    attribute :enviar_portador, type: Boolean, default: false
    validates :url_retorno, :presence => true, :length => {:maximum => 1024}
    validates :autorizar, :inclusion => {:in => AUTORIZACOES}
    attribute :campo_livre, type: String
    
    def root_attributes
      %w(url_retorno autorizar capturar campo_livre bin)
    end
  end
end