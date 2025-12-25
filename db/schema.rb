ActiveRecord::Schema[8.0].define(version: 2025_12_25_044655) do
  enable_extension "pg_catalog.plpgsql"

  create_table "comments", force: :cascade do |t|
    t.bigint "post_id", null: false
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id"], name: "index_comments_on_post_id"
  end

  create_table "posts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "wallets", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "balance", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "lock_version", default: 0, null: false
    t.index ["user_id"], name: "index_wallets_on_user_id", unique: true
  end

  add_foreign_key "comments", "posts"
  add_foreign_key "posts", "users"
  add_foreign_key "wallets", "users"
end
