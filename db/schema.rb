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

ActiveRecord::Schema[8.1].define(version: 2026_05_11_170306) do
  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "block_image_sets", force: :cascade do |t|
  end

  create_table "block_images", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "file_data"
    t.datetime "updated_at", null: false
  end

  create_table "block_rich_texts", force: :cascade do |t|
    t.text "content"
  end

  create_table "blocks", force: :cascade do |t|
    t.integer "blockable_id", null: false
    t.string "blockable_type", null: false
    t.integer "children_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.integer "depth", default: 0, null: false
    t.integer "lft", null: false
    t.integer "parent_id"
    t.integer "resource_id", null: false
    t.string "resource_type", null: false
    t.integer "rgt", null: false
    t.datetime "updated_at", null: false
    t.index ["blockable_type", "blockable_id"], name: "index_blocks_on_blockable"
    t.index ["depth"], name: "index_blocks_on_depth"
    t.index ["lft"], name: "index_blocks_on_lft"
    t.index ["parent_id"], name: "index_blocks_on_parent_id"
    t.index ["resource_type", "resource_id"], name: "index_blocks_on_resource"
    t.index ["rgt"], name: "index_blocks_on_rgt"
  end

  create_table "federails_activities", force: :cascade do |t|
    t.string "action", null: false
    t.integer "actor_id", null: false
    t.string "cc"
    t.datetime "created_at", null: false
    t.integer "entity_id", null: false
    t.string "entity_type", null: false
    t.string "to"
    t.datetime "updated_at", null: false
    t.string "uuid"
    t.index ["actor_id"], name: "index_federails_activities_on_actor_id"
    t.index ["entity_type", "entity_id"], name: "index_federails_activities_on_entity"
    t.index ["uuid"], name: "index_federails_activities_on_uuid", unique: true
  end

  create_table "federails_actors", force: :cascade do |t|
    t.string "actor_type"
    t.datetime "created_at", null: false
    t.integer "entity_id"
    t.string "entity_type"
    t.json "extensions"
    t.string "federated_url"
    t.string "followers_url"
    t.string "followings_url"
    t.string "inbox_url"
    t.boolean "local", default: false, null: false
    t.string "name"
    t.string "outbox_url"
    t.text "private_key"
    t.string "profile_url"
    t.text "public_key"
    t.string "server"
    t.datetime "tombstoned_at"
    t.datetime "updated_at", null: false
    t.string "username"
    t.string "uuid"
    t.index ["entity_type", "entity_id"], name: "index_federails_actors_on_entity", unique: true
    t.index ["federated_url"], name: "index_federails_actors_on_federated_url", unique: true
    t.index ["uuid"], name: "index_federails_actors_on_uuid", unique: true
  end

  create_table "federails_followings", force: :cascade do |t|
    t.integer "actor_id", null: false
    t.datetime "created_at", null: false
    t.string "federated_url"
    t.integer "status", default: 0
    t.integer "target_actor_id", null: false
    t.datetime "updated_at", null: false
    t.string "uuid"
    t.index ["actor_id", "target_actor_id"], name: "index_federails_followings_on_actor_id_and_target_actor_id", unique: true
    t.index ["actor_id"], name: "index_federails_followings_on_actor_id"
    t.index ["target_actor_id"], name: "index_federails_followings_on_target_actor_id"
    t.index ["uuid"], name: "index_federails_followings_on_uuid", unique: true
  end

  create_table "federails_hosts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "domain", null: false
    t.string "nodeinfo_url"
    t.text "protocols", default: "[]"
    t.text "services", default: "{}"
    t.string "software_name"
    t.string "software_version"
    t.datetime "updated_at", null: false
    t.index ["domain"], name: "index_federails_hosts_on_domain", unique: true
  end

  create_table "inbound_request_logs", force: :cascade do |t|
    t.string "client_reference"
    t.datetime "created_at", null: false
    t.datetime "ended_at"
    t.integer "loggable_id"
    t.string "loggable_type"
    t.string "method"
    t.string "path"
    t.text "request_body"
    t.text "response_body"
    t.integer "response_code"
    t.datetime "started_at"
    t.datetime "updated_at", null: false
    t.index ["client_reference"], name: "index_inbound_request_logs_on_client_reference"
    t.index ["loggable_type", "loggable_id"], name: "index_inbound_request_logs_on_loggable"
  end

  create_table "outbound_request_logs", force: :cascade do |t|
    t.string "client_reference"
    t.datetime "created_at", null: false
    t.datetime "ended_at"
    t.integer "loggable_id"
    t.string "loggable_type"
    t.string "method"
    t.string "path"
    t.text "request_body"
    t.text "response_body"
    t.integer "response_code"
    t.datetime "started_at"
    t.datetime "updated_at", null: false
    t.index ["client_reference"], name: "index_outbound_request_logs_on_client_reference"
    t.index ["loggable_type", "loggable_id"], name: "index_outbound_request_logs_on_loggable"
  end

  create_table "posts", force: :cascade do |t|
    t.integer "announces_count", default: 0
    t.text "content"
    t.datetime "created_at", null: false
    t.integer "federails_actor_id"
    t.string "federated_url"
    t.integer "likes_count", default: 0
    t.datetime "published_at"
    t.integer "site_id", null: false
    t.integer "sketch_of_id"
    t.string "state", default: "initialized", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["federails_actor_id"], name: "index_posts_on_federails_actor_id"
    t.index ["site_id"], name: "index_posts_on_site_id"
    t.index ["sketch_of_id"], name: "index_posts_on_sketch_of_id"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "sites", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "domain"
    t.text "logo_data"
    t.string "name"
    t.text "summary"
    t.integer "template_id"
    t.datetime "updated_at", null: false
    t.string "username"
    t.index ["domain"], name: "index_sites_on_domain", unique: true
    t.index ["template_id"], name: "index_sites_on_template_id"
    t.index ["username"], name: "index_sites_on_username", unique: true
  end

  create_table "templates", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "markup"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "name"
    t.string "password_digest", null: false
    t.integer "site_id", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["site_id"], name: "index_users_on_site_id"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "federails_activities", "federails_actors", column: "actor_id"
  add_foreign_key "federails_followings", "federails_actors", column: "actor_id"
  add_foreign_key "federails_followings", "federails_actors", column: "target_actor_id"
  add_foreign_key "posts", "federails_actors"
  add_foreign_key "posts", "posts", column: "sketch_of_id"
  add_foreign_key "posts", "sites"
  add_foreign_key "posts", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "sites", "templates"
  add_foreign_key "users", "sites"
end
