module Spree
  module CieloBasePayment
    extend ActiveSupport::Concern

    included do
      attr_accessor :order_id
      has_one :payment, :as => :source
      delegate :order, :to => :payment
    end

    def process!(payment)
      payment.pend
      redirect_url = "#{Spree::Config[:site_url]}/cielo/orders/#{order.number}/payments/#{payment.id}/verify"

      cielo_regular_transaction = transaction_class.new(
        dados_ec_numero: payment.payment_method.preferred_numero_afiliacao,
        dados_ec_chave: payment.payment_method.preferred_chave_acesso,
        cielo_environment: payment.payment_method.preferred_cielo_environment,
        url_retorno: redirect_url,
        dados_pedido_numero: order.number,
        dados_pedido_valor: order.total,
        forma_pagamento_bandeira: cc_type,
        forma_pagamento_parcelas: instalments,
        autorizar: authorize_code
      )
      if cielo_regular_transaction.save!
        self.tid = cielo_regular_transaction.tid
        self.authentication_url = cielo_regular_transaction.authentication_url
        self.status = cielo_regular_transaction.status
        if order.respond_to? :instalments
          order.instalments = instalments
          order.save
        end
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
      %w{capture void credit verify}
    end
    
    # Indicates whether its possible to capture the payment
    def can_capture?(payment)
      payment.state == 'pending' && payment.source.status_sym == :authorized_pending_capture
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
    
    def status_sym
      Cielo::Transaction::Base::STATUSES.key(status)
    end
    
    def verify(payment)
      if tid.blank?
        payment.started_processing; payment.failure
        return
      end
      t = Cielo::Transaction::Base.new( tid: tid, 
                                        dados_ec_numero: payment.payment_method.preferred_numero_afiliacao,
                                        dados_ec_chave: payment.payment_method.preferred_chave_acesso,
                                        cielo_environment: payment.payment_method.preferred_cielo_environment
                                      )
      t.verify!
      update_attribute :status, t.status
      record_log payment, t.body
      case Cielo::Transaction::Base::STATUSES.key(t.status)
        when :captured
          payment.complete
        when :in_progress
          return true
        when :authorized_pending_capture
          payment.started_processing
          capture(payment)
        else
          payment.started_processing; payment.failure
      end
      return true
    end

    def capture(payment)
      if tid.blank?
        payment.started_processing; payment.failure
        return
      end
      t = Cielo::Transaction::Base.new( tid: tid, 
                                        dados_ec_numero: payment.payment_method.preferred_numero_afiliacao,
                                        dados_ec_chave: payment.payment_method.preferred_chave_acesso,
                                        cielo_environment: payment.payment_method.preferred_cielo_environment
                                      )
      t.capture!
      update_attribute :status, t.status
      record_log payment, t.body
      if t.captured?
        payment.complete
        return true
      else
        return false
      end
    end

    def void(payment)
      return nil if tid.blank?
      t = Cielo::Transaction::Base.new( tid: tid, 
                                        dados_ec_numero: payment.payment_method.preferred_numero_afiliacao,
                                        dados_ec_chave: payment.payment_method.preferred_chave_acesso,
                                        cielo_environment: payment.payment_method.preferred_cielo_environment
                                      )
      t.void!
      update_attribute :status, t.status
      record_log payment, t.body
      if t.cancelled?
        payment.pend;payment.void
        true
      else
        false
      end
    end
  end
end
