module Spree
  class CieloRegularPayment < ActiveRecord::Base
    include CieloBasePayment
    def authorize_code
      3
    end

    def transaction_class
      ::Cielo::Transaction::Regular
    end
  end
end

