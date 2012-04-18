Spree::Core::Engine.routes.prepend do
  match "/cielo/orders/:order_number/payments/:payment_id/return", :to => "cielo#return", :as => :return_cielo
end