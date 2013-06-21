module Spree
  class PaymentMethod::CieloDebitMethod < PaymentMethod
    preference :numero_afiliacao, :string, :default => ::Cielo.numero_afiliacao
    preference :chave_acesso, :string, :default => ::Cielo.chave_acesso
    preference :maximo_parcelas, :integer, :default => 1
    preference :cielo_environment, :string, :default => "Test"
    attr_accessible :preferred_numero_afiliacao, :preferred_chave_acesso, :preferred_maximo_parcelas, :preferred_cielo_environment
    
    # def payment_profiles_supported?
    #   true
    # end
    # 
    # def process_before_confirm?
    #   true
    # end
    
    def payment_source_class
      CieloDebitPayment
    end
  end
end