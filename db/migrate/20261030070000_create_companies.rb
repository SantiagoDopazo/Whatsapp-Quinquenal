class CreateCompanies < ActiveRecord::Migration[8.1]
  def change
    create_table :companies do |t|
      t.string :name, null: false
      t.timestamps
    end

    add_reference :agents, :company, null: false, foreign_key: true
    add_reference :contacts, :company, null: false, foreign_key: true

    remove_index :contacts, :whatsapp_id, unique: true
    add_index :contacts, [ :company_id, :whatsapp_id ], unique: true
  end
end
