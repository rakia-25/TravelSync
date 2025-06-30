class AddRoleFirstnameLastnameAndPhoneToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :role, :string
    add_column :users, :phone, :integer
    add_column :users, :firts_name, :string
    add_column :users, :last_name, :string
  end
end
