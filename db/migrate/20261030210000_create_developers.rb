class CreateDevelopers < ActiveRecord::Migration[8.1]
  def change
    create_table :developers do |t|
      t.string :email, null: false, default: ""
      t.string :encrypted_password, null: false, default: ""
      t.string :name, null: false
      t.timestamps
    end
    add_index :developers, :email, unique: true
  end
end
