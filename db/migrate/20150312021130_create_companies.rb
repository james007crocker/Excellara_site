class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string :name
      t.string :email
      t.string :location
      t.integer :size
      t.text :description

      t.timestamps null: false
    end
  end
end
