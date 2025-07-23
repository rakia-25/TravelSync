class CreatePayments < ActiveRecord::Migration[7.1]
  def change
    create_table :payments do |t|
      t.decimal :amount
      t.string :payment_method
      t.string :status
      t.references :reservation, null: false, foreign_key: true

      t.timestamps
    end
  end
end
