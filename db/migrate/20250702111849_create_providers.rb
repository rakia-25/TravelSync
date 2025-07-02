class CreateProviders < ActiveRecord::Migration[7.1]
  def change
    create_table :providers do |t|
      t.string :business
      t.string :type
      t.string :address
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
