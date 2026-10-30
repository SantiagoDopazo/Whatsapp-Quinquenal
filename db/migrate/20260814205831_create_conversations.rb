class CreateConversations < ActiveRecord::Migration[8.1]
  def change
    create_table :conversations do |t|
      t.references :contact, null: false, foreign_key: true
      t.references :agent, null: true, foreign_key: true
      t.integer :status, null: false, default: 0
      t.datetime :last_activity_at

      t.timestamps
    end
  end
end
