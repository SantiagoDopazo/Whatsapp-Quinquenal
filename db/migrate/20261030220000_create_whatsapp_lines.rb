class CreateWhatsappLines < ActiveRecord::Migration[8.1]
  def change
    create_table :whatsapp_accounts do |t|
      t.references :company, null: false, foreign_key: true
      t.string :name, null: false
      t.string :external_id, null: false
      t.string :status, null: false, default: "pending"
      t.timestamps
    end
    add_index :whatsapp_accounts, :external_id, unique: true
    add_check_constraint :whatsapp_accounts, "status IN ('pending', 'connected', 'disabled')", name: "whatsapp_accounts_valid_status"

    create_table :phone_numbers do |t|
      t.references :whatsapp_account, null: false, foreign_key: true
      t.string :name, null: false
      t.string :external_id, null: false
      t.string :display_phone_number, null: false
      t.string :status, null: false, default: "pending"
      t.timestamps
    end
    add_index :phone_numbers, :external_id, unique: true
    add_check_constraint :phone_numbers, "status IN ('pending', 'connected', 'disabled')", name: "phone_numbers_valid_status"

    create_table :phone_number_accesses do |t|
      t.references :agent, null: false, foreign_key: true
      t.references :phone_number, null: false, foreign_key: true
      t.timestamps
    end
    add_index :phone_number_accesses, [ :agent_id, :phone_number_id ], unique: true

    add_reference :conversations, :phone_number, foreign_key: true
    add_index :conversations, [ :contact_id, :phone_number_id ], unique: true,
      where: "phone_number_id IS NOT NULL AND status IN (0, 1)", name: "index_conversations_on_active_contact_line"
  end
end
