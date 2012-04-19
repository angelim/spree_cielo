Deface::Override.new(
  virtual_path: "spree/shared/_order_details",
  name: "add_cielo_payment_info",
  insert_bottom: ".payment-info",
  partial: "spree/checkout/payment/cielo_order_details"
)