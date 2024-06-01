class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :name
      t.float :price
      t.string :image
      t.string :description

      t.timestamps
    end
  end
end
