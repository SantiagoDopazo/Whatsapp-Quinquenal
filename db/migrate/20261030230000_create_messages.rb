class CreateMessages < ActiveRecord::Migration[8.1]
  def change
    add_index :conversations, [ :id, :phone_number_id ], unique: true

    create_table :messages do |t|
      t.references :conversation, null: false
      t.references :phone_number, null: false, foreign_key: true
      t.references :agent, foreign_key: { on_delete: :nullify }
      t.string :direction, null: false
      t.string :message_type, null: false, default: "text"
      t.string :status, null: false
      t.text :body
      t.string :external_id
      t.string :client_request_id
      t.datetime :occurred_at, null: false
      t.datetime :status_at, null: false
      t.timestamps
    end
    add_foreign_key :messages, :conversations, column: [ :conversation_id, :phone_number_id ], primary_key: [ :id, :phone_number_id ]
    add_index :messages, [ :phone_number_id, :external_id ], unique: true, where: "external_id IS NOT NULL"
    add_index :messages, [ :phone_number_id, :client_request_id ], unique: true, where: "client_request_id IS NOT NULL"
    add_index :messages, [ :conversation_id, :occurred_at, :id ]
    add_check_constraint :messages, "direction IN ('inbound', 'outbound')", name: "messages_valid_direction"
    add_check_constraint :messages, "message_type IN ('text', 'unsupported')", name: "messages_valid_type"
    add_check_constraint :messages, "(direction = 'inbound' AND status = 'received' AND external_id IS NOT NULL) OR (direction = 'outbound' AND status IN ('queued', 'sending', 'accepted', 'sent', 'delivered', 'read', 'failed', 'unknown') AND client_request_id IS NOT NULL)", name: "messages_valid_direction_state"
    add_check_constraint :messages, "(message_type = 'text' AND body IS NOT NULL AND length(trim(body)) > 0) OR (message_type = 'unsupported' AND direction = 'inbound')", name: "messages_valid_content"
  end
end
