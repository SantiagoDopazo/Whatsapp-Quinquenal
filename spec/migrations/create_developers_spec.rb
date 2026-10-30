require "rails_helper"
require Rails.root.join("db/migrate/20261030210000_create_developers")

RSpec.describe CreateDevelopers, type: :model do
  let(:connection) { ActiveRecord::Base.connection }
  let(:original_path) { connection.schema_search_path }
  let(:schema) { "developers_migration_#{SecureRandom.hex(8)}" }
  let(:migration) { described_class.new }

  before do
    original_path
    connection.execute("CREATE SCHEMA #{connection.quote_table_name(schema)}")
    connection.schema_search_path = schema
  end

  after do
    connection.schema_search_path = original_path
    connection.execute("DROP SCHEMA IF EXISTS #{connection.quote_table_name(schema)} CASCADE")
    connection.schema_cache.clear!
  end

  it "adds an empty internal identity table and rolls back" do
    migration.migrate(:up)
    expect(connection.table_exists?(:developers)).to be(true)
    expect(connection.column_exists?(:developers, :company_id)).to be(false)
    expect(connection.index_exists?(:developers, :email, unique: true)).to be(true)
    expect(connection.select_value("SELECT COUNT(*) FROM developers")).to eq(0)
    migration.migrate(:down)
    expect(connection.table_exists?(:developers)).to be(false)
  end
end
