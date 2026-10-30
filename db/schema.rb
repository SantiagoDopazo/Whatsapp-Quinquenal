# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_10_30_220000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "agents", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "jti", null: false
    t.string "name", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "role", default: "agent", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_agents_on_company_id"
    t.index ["email"], name: "index_agents_on_email", unique: true
    t.index ["jti"], name: "index_agents_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_agents_on_reset_password_token", unique: true
  end

  create_table "companies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "contacts", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.string "whatsapp_id", null: false
    t.index ["company_id", "whatsapp_id"], name: "index_contacts_on_company_id_and_whatsapp_id", unique: true
    t.index ["company_id"], name: "index_contacts_on_company_id"
  end

  create_table "conversations", force: :cascade do |t|
    t.bigint "agent_id"
    t.bigint "contact_id", null: false
    t.datetime "created_at", null: false
    t.datetime "last_activity_at"
    t.bigint "phone_number_id"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["agent_id"], name: "index_conversations_on_agent_id"
    t.index ["contact_id", "phone_number_id"], name: "index_conversations_on_active_contact_line", unique: true, where: "((phone_number_id IS NOT NULL) AND (status = ANY (ARRAY[0, 1])))"
    t.index ["contact_id"], name: "index_conversations_on_contact_id"
    t.index ["phone_number_id"], name: "index_conversations_on_phone_number_id"
  end

  create_table "developers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_developers_on_email", unique: true
  end

  create_table "jwt_denylists", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "exp"
    t.string "jti"
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_jwt_denylists_on_jti"
  end

  create_table "phone_number_accesses", force: :cascade do |t|
    t.bigint "agent_id", null: false
    t.datetime "created_at", null: false
    t.bigint "phone_number_id", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_id", "phone_number_id"], name: "index_phone_number_accesses_on_agent_id_and_phone_number_id", unique: true
    t.index ["agent_id"], name: "index_phone_number_accesses_on_agent_id"
    t.index ["phone_number_id"], name: "index_phone_number_accesses_on_phone_number_id"
  end

  create_table "phone_numbers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "display_phone_number", null: false
    t.string "external_id", null: false
    t.string "name", null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.bigint "whatsapp_account_id", null: false
    t.index ["external_id"], name: "index_phone_numbers_on_external_id", unique: true
    t.index ["whatsapp_account_id"], name: "index_phone_numbers_on_whatsapp_account_id"
    t.check_constraint "status::text = ANY (ARRAY['pending'::character varying, 'connected'::character varying, 'disabled'::character varying]::text[])", name: "phone_numbers_valid_status"
  end

  create_table "whatsapp_accounts", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.string "external_id", null: false
    t.string "name", null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_whatsapp_accounts_on_company_id"
    t.index ["external_id"], name: "index_whatsapp_accounts_on_external_id", unique: true
    t.check_constraint "status::text = ANY (ARRAY['pending'::character varying, 'connected'::character varying, 'disabled'::character varying]::text[])", name: "whatsapp_accounts_valid_status"
  end

  add_foreign_key "agents", "companies"
  add_foreign_key "contacts", "companies"
  add_foreign_key "conversations", "agents"
  add_foreign_key "conversations", "contacts"
  add_foreign_key "conversations", "phone_numbers"
  add_foreign_key "phone_number_accesses", "agents"
  add_foreign_key "phone_number_accesses", "phone_numbers"
  add_foreign_key "phone_numbers", "whatsapp_accounts"
  add_foreign_key "whatsapp_accounts", "companies"
end
