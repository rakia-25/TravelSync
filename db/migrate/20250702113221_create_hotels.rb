class CreateHotels < ActiveRecord::Migration[7.1]
  def change
    create_table :hotels do |t|
      t.string :name
      t.string :description
      t.integer :stars
      t.string :address
      t.string :city
      t.string :gps
      t.string :service
      t.references :provider, null: false, foreign_key: true

      t.timestamps
    end
  end
end
