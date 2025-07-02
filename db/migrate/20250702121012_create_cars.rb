class CreateCars < ActiveRecord::Migration[7.1]
  def change
    create_table :cars do |t|
      t.references :provider, null: false, foreign_key: true
      t.string :brand
      t.string :type
      t.decimal :price
      t.string :options
      t.boolean :available
      t.string :model

      t.timestamps
    end
  end
end
