require "rails_helper"
require Rails.root.join("db/migrate/20260807195118_devise_create_agents")
require Rails.root.join("db/migrate/20260814164705_create_contacts")
require Rails.root.join("db/migrate/20260814205831_create_conversations")
require Rails.root.join("db/migrate/20261030070000_create_companies")

RSpec.describe CreateCompanies, type: :model do
  let(:connection) { ActiveRecord::Base.connection }
  let(:original_path) { connection.schema_search_path }
  let(:schema) { "company_migration_#{SecureRandom.hex(8)}" }
  let(:migration) { described_class.new }

  before do
    original_path
    connection.execute("CREATE SCHEMA #{connection.quote_table_name(schema)}")
    connection.schema_search_path = schema
    DeviseCreateAgents.new.migrate(:up)
    CreateContacts.new.migrate(:up)
    CreateConversations.new.migrate(:up)
  end

  after do
    connection.schema_search_path = original_path
    connection.execute("DROP SCHEMA IF EXISTS #{connection.quote_table_name(schema)} CASCADE")
    connection.schema_cache.clear!
  end

  it "migrates and rolls back the structure on an empty development database" do
    migration.migrate(:up)

    expect(connection.table_exists?(:companies)).to be(true)
    expect(connection.columns(:agents).find { |column| column.name == "company_id" }.null).to be(false)
    expect(connection.columns(:contacts).find { |column| column.name == "company_id" }.null).to be(false)
    expect(connection.index_exists?(:contacts, [ :company_id, :whatsapp_id ], unique: true)).to be(true)
    expect(connection.select_value("SELECT COUNT(*) FROM companies")).to eq(0)

    migration.migrate(:down)

    expect(connection.table_exists?(:companies)).to be(false)
    expect(connection.column_exists?(:agents, :company_id)).to be(false)
    expect(connection.column_exists?(:contacts, :company_id)).to be(false)
    expect(connection.index_exists?(:contacts, :whatsapp_id, unique: true)).to be(true)
  end
end
