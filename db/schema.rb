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

ActiveRecord::Schema.define(version: 2021_01_29_021350) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "goal_relationships", id: false, force: :cascade do |t|
    t.uuid "parent_id", null: false
    t.uuid "child_id", null: false
    t.index ["child_id"], name: "index_goal_relationships_on_child_id"
    t.index ["parent_id"], name: "index_goal_relationships_on_parent_id"
  end

  create_table "goals", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "state", default: 0, null: false
    t.uuid "tree_id", null: false
    t.integer "duration", default: 1
    t.integer "spent", default: 0
    t.index ["tree_id"], name: "index_goals_on_tree_id"
  end

  create_table "trees", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "goal_relationships", "goals", column: "child_id"
  add_foreign_key "goal_relationships", "goals", column: "parent_id"
  add_foreign_key "goals", "trees"
end
