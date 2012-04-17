module Spree
  class CieloRegularPayment < ActiveRecord::Base
    
    attr_accessor :order_id
    has_one :payment, :as => :source
    
    def process!(payment)
      order = payment.order
      
      redirect_url = "#{Spree::Config[:site_url]}/orders/#{order.number}"

      cielo_regular_transaction = ::Cielo::Transaction::Regular.new(
        cielo_environment: payment.payment_method.cielo_environment
        url_retorno: redirect_url,
        dados_pedido_numero: order.number,
        dados_pedido_valor: order.total,
        forma_pagamento_bandeira: cc_type,
        forma_pagamento_produto: product_type,
        forma_pagamento_parcelas: instalments,
      )
      if cielo_regular_transaction.save!
        response = cielo_regular_transaction.response
        self.tid = response[:transacao][:tid]
        self.authentication_url = response[:"url-autenticacao"]
        record_log payment, response
        if response
        self.save
      elsif cielo_regular_transaction.response[:errors].present?
        self.errors[:base] = 
      end
    end
    
    def actions
      %w{capture void credit}
    end

    # Indicates whether its possible to capture the payment
    def can_capture?(payment)
      payment.state == 'pending'
    end

    # Indicates whether its possible to void the payment.
    def can_void?(payment)
      payment.state == 'void' ? false : true
    end

    # Indicates whether its possible to credit the payment.  Note that most gateways require that the
    # payment be settled first which generally happens within 12-24 hours of the transaction.
    def can_credit?(payment)
      return false unless payment.state == 'completed'
      return false unless payment.order.payment_state == 'credit_owed'
      payment.credit_allowed > 0
    end

    def record_log(payment, response)
      payment.log_entries.create(:details => response.to_yaml)
    end

    def capture(payment)
      payment.update_attribute(:state, 'pending') if payment.state == 'checkout'
      payment.complete
      true
    end

    def void(payment)
      payment.update_attribute(:state, 'pending') if payment.state == 'checkout'
      payment.void
      true
    end
  end
end
