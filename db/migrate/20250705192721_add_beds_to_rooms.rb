class AddBedsToRooms < ActiveRecord::Migration[7.1]
  def change
    add_column :rooms, :beds, :integer, default: 1, null: false
  end
end
