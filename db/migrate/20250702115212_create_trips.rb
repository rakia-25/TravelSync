class CreateTrips < ActiveRecord::Migration[7.1]
  def change
    create_table :trips do |t|
      t.string :title
      t.string :theme
      t.text :program
      t.integer :duration
      t.date :departureDate
      t.date :returnDate
      t.string :departureCity
      t.string :destinationCity
      t.references :provider, null: false, foreign_key: true

      t.timestamps
    end
  end
end
