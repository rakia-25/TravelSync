class RenameTypeToNameInCars < ActiveRecord::Migration[7.1]
  def change
    rename_column :cars, :type, :name
  end
end
