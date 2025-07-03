class RenameFirtsnameToFirstnameInUsers < ActiveRecord::Migration[7.1]
  def change
    rename_column :users, :firts_name, :first_name
  end
end
