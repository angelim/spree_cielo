Spree::Payment.class_eval do
  scope :by_order, lambda{|payment_id, order_number| where(:id => payment_id, :spree_orders => { :number => order_number }).joins(:order).readonly(false)}
end