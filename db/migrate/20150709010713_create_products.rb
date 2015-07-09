class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :description
      t.integer :precio
      t.integer :cantidad

      t.timestamps null: false
    end
  end
end
