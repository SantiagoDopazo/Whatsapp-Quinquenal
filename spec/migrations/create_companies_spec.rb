require "rails_helper"
require Rails.root.join("db/migrate/20260807195118_devise_create_agents")
require Rails.root.join("db/migrate/20260814164705_create_contacts")
require Rails.root.join("db/migrate/20260814205831_create_conversations")
require Rails.root.join("db/migrate/20261030070000_create_companies")

RSpec.describe CreateCompanies, type: :model do
  it "preserves existing agents, contacts and conversations when assigning ownership" do
    connection = ActiveRecord::Base.connection
    original_path = connection.schema_search_path
    schema = "company_migration_#{SecureRandom.hex(8)}"
    connection.execute("CREATE SCHEMA #{connection.quote_table_name(schema)}")

    begin
      connection.schema_search_path = schema
      DeviseCreateAgents.new.migrate(:up)
      CreateContacts.new.migrate(:up)
      CreateConversations.new.migrate(:up)

      connection.execute(<<~SQL)
        INSERT INTO agents (id, email, name, jti, created_at, updated_at)
        VALUES (1, 'existing@example.test', 'Existing agent', 'existing-jti', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
        INSERT INTO contacts (id, whatsapp_id, name, created_at, updated_at)
        VALUES (1, '5491100000000', 'Existing contact', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
        INSERT INTO conversations (id, agent_id, contact_id, status, created_at, updated_at)
        VALUES (1, 1, 1, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
      SQL

      described_class.new.migrate(:up)

      company_id = connection.select_value("SELECT id FROM companies WHERE name = 'La Quinquenal'")
      expect(company_id).to be_present
      expect(connection.select_value("SELECT company_id FROM agents WHERE id = 1")).to eq(company_id)
      expect(connection.select_value("SELECT company_id FROM contacts WHERE id = 1")).to eq(company_id)
      expect(connection.select_one("SELECT agent_id, contact_id, status FROM conversations WHERE id = 1"))
        .to eq("agent_id" => 1, "contact_id" => 1, "status" => 1)
    ensure
      connection.schema_search_path = original_path
      connection.execute("DROP SCHEMA #{connection.quote_table_name(schema)} CASCADE")
      connection.schema_cache.clear!
    end
  end
end
