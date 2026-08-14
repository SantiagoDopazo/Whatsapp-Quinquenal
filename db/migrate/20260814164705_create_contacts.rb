class CreateContacts < ActiveRecord::Migration[8.1]
  def change
    create_table :contacts do |t|
      t.string :whatsapp_id, null: false
      t.string :name
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end
    add_index :contacts, :whatsapp_id, unique: true
  end
end
