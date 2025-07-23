class AddPriceToTrips < ActiveRecord::Migration[7.1]
  def change
    add_column :trips, :price, :integer
  end
end
