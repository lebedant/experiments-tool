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

ActiveRecord::Schema.define(version: 20171105215937) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "double_data", force: :cascade do |t|
    t.decimal "value"
  end

  create_table "long_data", force: :cascade do |t|
    t.integer "value"
  end

  create_table "string_data", force: :cascade do |t|
    t.string "value"
  end

  create_table "test_data", force: :cascade do |t|
    t.integer "session_id"
    t.integer "target_id"
    t.string "target_type"
    t.bigint "test_variable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["test_variable_id"], name: "index_test_data_on_test_variable_id"
  end

  create_table "test_parts", force: :cascade do |t|
    t.string "access_token"
    t.string "name"
    t.string "description"
    t.integer "design_type"
    t.bigint "test_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["access_token"], name: "index_test_parts_on_access_token", unique: true
    t.index ["test_id"], name: "index_test_parts_on_test_id"
  end

  create_table "test_variables", force: :cascade do |t|
    t.integer "data_type"
    t.string "name"
    t.boolean "log_transform"
    t.bigint "test_part_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["test_part_id"], name: "index_test_variables_on_test_part_id"
  end

  create_table "tests", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_tests_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "authentication_token", limit: 30
    t.index ["authentication_token"], name: "index_users_on_authentication_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
