class CreateCompanies < ActiveRecord::Migration[8.1]
  def up
    create_table :companies do |t|
      t.string :name, null: false
      t.timestamps
    end

    add_reference :agents, :company, foreign_key: true
    add_reference :contacts, :company, foreign_key: true

    company_id = select_value(<<~SQL)
      INSERT INTO companies (name, created_at, updated_at)
      VALUES ('La Quinquenal', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
      RETURNING id
    SQL

    execute "UPDATE agents SET company_id = #{connection.quote(company_id)}"
    execute "UPDATE contacts SET company_id = #{connection.quote(company_id)}"

    change_column_null :agents, :company_id, false
    change_column_null :contacts, :company_id, false
    remove_index :contacts, :whatsapp_id
    add_index :contacts, [ :company_id, :whatsapp_id ], unique: true
  end

  def down
    raise ActiveRecord::IrreversibleMigration,
      "Removing companies would discard ownership and may conflict with contacts shared across companies. Restore a backup instead."
  end
end
