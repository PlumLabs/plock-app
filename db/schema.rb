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

ActiveRecord::Schema[8.1].define(version: 2026_05_11_003760) do
  create_table "ai_chats", force: :cascade do |t|
    t.integer "ai_model_id"
    t.datetime "created_at", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["ai_model_id"], name: "index_ai_chats_on_ai_model_id"
    t.index ["user_id"], name: "index_ai_chats_on_user_id"
  end

  create_table "ai_messages", force: :cascade do |t|
    t.integer "ai_chat_id", null: false
    t.integer "ai_model_id"
    t.integer "ai_tool_call_id"
    t.integer "cache_creation_tokens"
    t.integer "cached_tokens"
    t.text "content"
    t.json "content_raw"
    t.datetime "created_at", null: false
    t.integer "input_tokens"
    t.integer "output_tokens"
    t.string "role", null: false
    t.text "thinking_signature"
    t.text "thinking_text"
    t.integer "thinking_tokens"
    t.datetime "updated_at", null: false
    t.index ["ai_chat_id"], name: "index_ai_messages_on_ai_chat_id"
    t.index ["ai_model_id"], name: "index_ai_messages_on_ai_model_id"
    t.index ["ai_tool_call_id"], name: "index_ai_messages_on_ai_tool_call_id"
    t.index ["role"], name: "index_ai_messages_on_role"
  end

  create_table "ai_models", force: :cascade do |t|
    t.json "capabilities", default: []
    t.integer "context_window"
    t.datetime "created_at", null: false
    t.string "family"
    t.date "knowledge_cutoff"
    t.integer "max_output_tokens"
    t.json "metadata", default: {}
    t.json "modalities", default: {}
    t.datetime "model_created_at"
    t.string "model_id", null: false
    t.string "name", null: false
    t.json "pricing", default: {}
    t.string "provider", null: false
    t.datetime "updated_at", null: false
    t.index ["family"], name: "index_ai_models_on_family"
    t.index ["provider", "model_id"], name: "index_ai_models_on_provider_and_model_id", unique: true
    t.index ["provider"], name: "index_ai_models_on_provider"
  end

  create_table "ai_tool_calls", force: :cascade do |t|
    t.integer "ai_message_id", null: false
    t.json "arguments", default: {}
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.text "thought_signature"
    t.string "tool_call_id", null: false
    t.datetime "updated_at", null: false
    t.index ["ai_message_id"], name: "index_ai_tool_calls_on_ai_message_id"
    t.index ["name"], name: "index_ai_tool_calls_on_name"
    t.index ["tool_call_id"], name: "index_ai_tool_calls_on_tool_call_id", unique: true
  end

  create_table "clients", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "disabled_at"
    t.string "email"
    t.string "name"
    t.text "note"
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_clients_on_name"
  end

  create_table "project_assignments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "project_id", null: false
    t.string "role", default: "member", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["project_id"], name: "index_project_assignments_on_project_id"
    t.index ["user_id", "project_id"], name: "index_project_assignments_on_user_id_and_project_id", unique: true
    t.index ["user_id"], name: "index_project_assignments_on_user_id"
  end

  create_table "projects", force: :cascade do |t|
    t.integer "client_id"
    t.datetime "created_at", null: false
    t.datetime "disabled_at"
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_projects_on_client_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "time_entries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.text "description"
    t.integer "duration_minutes", default: 0, null: false
    t.integer "project_id"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["project_id"], name: "index_time_entries_on_project_id"
    t.index ["user_id"], name: "index_time_entries_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "disabled_at"
    t.string "email_address", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "password_digest", null: false
    t.string "role", default: "member"
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "ai_chats", "ai_models"
  add_foreign_key "ai_chats", "users"
  add_foreign_key "ai_messages", "ai_chats"
  add_foreign_key "ai_messages", "ai_models"
  add_foreign_key "ai_messages", "ai_tool_calls"
  add_foreign_key "ai_tool_calls", "ai_messages"
  add_foreign_key "project_assignments", "projects"
  add_foreign_key "project_assignments", "users"
  add_foreign_key "projects", "clients"
  add_foreign_key "sessions", "users"
  add_foreign_key "time_entries", "projects"
  add_foreign_key "time_entries", "users"
end
