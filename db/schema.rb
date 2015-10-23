# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151023023026) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false, index: {name: "index_users_on_email", unique: true, using: :btree}
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token",   index: {name: "index_users_on_reset_password_token", unique: true, using: :btree}
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "support_sources", force: :cascade do |t|
    t.string   "type",                  null: false
    t.string   "name",                  null: false
    t.integer  "user_id",               null: false, foreign_key: {references: "users", name: "fk_support_sources_user_id", on_update: :cascade, on_delete: :cascade}, index: {name: "fk__support_sources_user_id", using: :btree}
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.string   "github_owner_and_repo"
    t.string   "supportbee_company_id"
    t.string   "supportbee_auth_token"
    t.string   "supportbee_user_id"
    t.integer  "supportbee_group_id"
  end

  create_table "tickets", force: :cascade do |t|
    t.integer  "support_source_id", null: false, foreign_key: {references: "support_sources", name: "fk_tickets_support_source_id", on_update: :cascade, on_delete: :cascade}, index: {name: "fk__tickets_support_source_id", using: :btree}
    t.string   "title",             null: false
    t.string   "external_id"
    t.integer  "status",            default: 0, null: false
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

end
