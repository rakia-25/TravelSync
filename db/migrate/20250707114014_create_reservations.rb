class CreateReservations < ActiveRecord::Migration[7.1]
  def change
    create_table :reservations do |t|
      t.references :user, null: false, foreign_key: true
      t.date :start_date
      t.date :end_date
      t.string :status
      t.integer :nbre_person
      t.references :reservable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
