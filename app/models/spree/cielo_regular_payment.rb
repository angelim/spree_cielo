module Spree
  class CieloRegularPayment < ActiveRecord::Base
    include CieloBasePayment
    attr_accessible :order_id, :cc_type, :instalments
    def authorize_code
      3
    end

    def transaction_class
      ::Cielo::Transaction::Regular
    end
  end
end

