require "rails_helper"
require Rails.root.join("db/migrate/20260807195118_devise_create_agents")
require Rails.root.join("db/migrate/20260814164705_create_contacts")
require Rails.root.join("db/migrate/20260814205831_create_conversations")
require Rails.root.join("db/migrate/20261030070000_create_companies")
require Rails.root.join("db/migrate/20261030220000_create_whatsapp_lines")

RSpec.describe CreateWhatsappLines, type: :model do
  let(:connection) { ActiveRecord::Base.connection }
  let(:original_path) { connection.schema_search_path }
  let(:schema) { "lines_migration_#{SecureRandom.hex(8)}" }
  let(:migration) { described_class.new }

  before do
    original_path
    connection.execute("CREATE SCHEMA #{connection.quote_table_name(schema)}")
    connection.schema_search_path = schema
    DeviseCreateAgents.new.migrate(:up)
    CreateContacts.new.migrate(:up)
    CreateConversations.new.migrate(:up)
    CreateCompanies.new.migrate(:up)
    connection.execute("INSERT INTO companies (id, name, created_at, updated_at) VALUES (1, 'Test', NOW(), NOW())")
    connection.execute("INSERT INTO contacts (id, company_id, whatsapp_id, created_at, updated_at) VALUES (1, 1, 'synthetic', NOW(), NOW())")
    connection.execute("INSERT INTO conversations (id, contact_id, created_at, updated_at) VALUES (1, 1, NOW(), NOW())")
  end

  after do
    connection.schema_search_path = original_path
    connection.execute("DROP SCHEMA IF EXISTS #{connection.quote_table_name(schema)} CASCADE")
    connection.schema_cache.clear!
  end

  it "preserves old chats without inventing a line and rolls back without deleting them" do
    migration.migrate(:up)
    expect(connection.table_exists?(:phone_number_accesses)).to be(false)
    expect(connection.select_value("SELECT phone_number_id FROM conversations WHERE id = 1")).to be_nil
    expect(connection.select_value("SELECT COUNT(*) FROM phone_numbers")).to eq(0)
    migration.migrate(:down)
    expect(connection.select_value("SELECT contact_id FROM conversations WHERE id = 1")).to eq(1)
    expect(connection.column_exists?(:conversations, :phone_number_id)).to be(false)
  end
end
