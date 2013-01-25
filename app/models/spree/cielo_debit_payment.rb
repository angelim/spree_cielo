module Spree
  class CieloDebitPayment < ActiveRecord::Base
    include CieloBasePayment
    def authorize_code
      1
    end

    def transaction_class
      ::Cielo::Transaction::Debit
    end
  end
end