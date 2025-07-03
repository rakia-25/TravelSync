class RenameTypeToTypeproviderInProviders < ActiveRecord::Migration[7.1]
  def change
    rename_column :providers, :type, :type_provider
  end
end
