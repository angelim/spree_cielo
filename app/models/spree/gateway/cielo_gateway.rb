module Spree
  class Gateway::CieloGateway < Gateway

    def provider_class
      SpreeCielo::Client
    end

    def payment_profiles_supported?
      false
    end

    def create_profile(payment)
      amount = (payment.amount * 100).round
      creditcard = payment.source
      if creditcard.gateway_customer_profile_id.nil?
        profile_id = provider.add_customer(amount, creditcard, creditcard.gateway_options(payment))
        creditcard.update_attributes(:gateway_customer_profile_id => profile_id,
                                     :gateway_payment_profile_id => 0)
      end
    end

  end
end
