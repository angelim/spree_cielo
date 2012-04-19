module Spree
  class CieloRegularPayment < ActiveRecord::Base
    
    attr_accessor :order_id
    has_one :payment, :as => :source
    delegate :order, :to => :payment
    
    def process!(payment)
      redirect_url = "#{Spree::Config[:site_url]}/cielo/orders/#{order.number}/payments/#{payment.id}/return"

      cielo_regular_transaction = ::Cielo::Transaction::Regular.new(
        dados_ec_numero: payment.payment_method.preferred_numero_afiliacao,
        dados_ec_chave: payment.payment_method.preferred_chave_acesso,
        cielo_environment: payment.payment_method.preferred_cielo_environment,
        url_retorno: redirect_url,
        dados_pedido_numero: order.number,
        dados_pedido_valor: order.total,
        forma_pagamento_bandeira: cc_type,
        forma_pagamento_produto: product_type,
        forma_pagamento_parcelas: instalments,
      )
      if cielo_regular_transaction.save!
        self.tid = cielo_regular_transaction.tid
        self.authentication_url = cielo_regular_transaction.authentication_url
        self.status = cielo_regular_transaction.status
        record_log payment, cielo_regular_transaction.body
        if cielo_regular_transaction.errors.empty?
          self.save
        else
          raise Cielo::PaymentError.new(cielo_regular_transaction.errors.full_messages)
        end
      else
        record_log payment, cielo_regular_transaction.errors
        raise Cielo::PaymentError.new(cielo_regular_transaction.errors.full_messages)
      end
    end
    
    def actions
      %w{capture void credit verify retry_capture}
    end
    
    def retry_capture(payment)
      
    end

    # Indicates whether its possible to capture the payment
    def can_capture?(payment)
      payment.state == 'pending'
    end
    
    def can_verify?(payment)
      tid.present?
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
    
    def verify(payment)
      return nil if tid.blank?
      t = Cielo::Transaction::Base.new(:tid => tid)
      t.verify!
      record_log payment, t.body
      case Cielo::Transaction::Base::STATUSES.key(t.status)
        when :captured
          payment.complete
        when :in_progress, :authentication_in_progress
          return
        when :authenticated
          payment.started_processing
          capture(payment)
        else
          payment.started_processing; payment.failure
      end
    end

    def capture(payment)
      return nil if tid.blank?
      t = Cielo::Transaction::Base.new(:tid => tid)
      t.capture!
      record_log payment, t.body
      if t.captured?
        payment.complete
        true
      else
        false
      end
    end

    def void(payment)
      return nil if tid.blank?
      t = Cielo::Transaction::Base.new(:tid => tid)
      t.void!
      record_log payment, t.body
      if t.cancelled?
        payment.void
        true
      else
        false
      end
    end
  end
end
