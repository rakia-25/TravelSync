class CreateRooms < ActiveRecord::Migration[7.1]
  def change
    create_table :rooms do |t|
      t.references :hotel, null: false, foreign_key: true
      t.string :services
      t.string :type
      t.decimal :price
      t.boolean :available

      t.timestamps
    end
  end
end
