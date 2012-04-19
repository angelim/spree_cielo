Spree::Core::Engine.routes.prepend do
  match "/cielo/orders/:order_number/payments/:payment_id/verify", :to => "cielo#verify", :as => :verify_cielo
  match "/cielo/orders/:order_number/payments/:payment_id/reauthenticate", :to => "cielo#reauthenticate", :as => :reauthenticate_cielo
end