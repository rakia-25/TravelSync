class RenameTypeToTyperoomInRooms < ActiveRecord::Migration[7.1]
  def change
    rename_column :rooms, :type, :type_room
  end
end
