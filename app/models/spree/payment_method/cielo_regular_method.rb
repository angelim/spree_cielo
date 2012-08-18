module Spree
  class PaymentMethod::CieloRegularMethod < PaymentMethod
    preference :numero_afiliacao, :string, :default => ::Cielo.numero_afiliacao
    preference :chave_acesso, :string, :default => ::Cielo.chave_acesso
    preference :maximo_parcelas, :integer, :default => 3
    preference :cielo_environment, :string, :default => "Test"

    attr_accessible :preferred_numero_afiliacao, :preferred_chave_acesso, :preferred_maximo_parcelas, :preferred_cielo_environment

    def payment_source_class
      CieloRegularPayment
    end

    def authorize(amount, source, options = {})
      source.process! source.payment
    end

    def purchase
      raise StandardError.new(I18n.t(:must_authorize_for_regular_cielo))
    end

  end
end
