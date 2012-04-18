class CreateCieloRegularPayments < ActiveRecord::Migration
  def change
    create_table :spree_cielo_regular_payments do |t|
      t.string :tid
      t.string :authentication_url
      t.string :cc_type
      t.string :instalments
      t.string :product_type
      t.integer :status
      t.timestamps
    end
  end
end
