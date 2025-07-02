class CreateHotelTrips < ActiveRecord::Migration[7.1]
  def change
    create_table :hotel_trips do |t|
      t.references :hotel, null: false, foreign_key: true
      t.references :trip, null: false, foreign_key: true

      t.timestamps
    end
  end
end
