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

ActiveRecord::Schema.define(version: 20141008142656) do

  create_table "bootsy_image_galleries", force: true do |t|
    t.integer  "bootsy_resource_id"
    t.string   "bootsy_resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bootsy_images", force: true do |t|
    t.string   "image_file"
    t.integer  "image_gallery_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "friendly_id_slugs", force: true do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"

  create_table "post_data", force: true do |t|
    t.string   "title",       null: false
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_url"
    t.datetime "pubdate"
    t.string   "author_name"
    t.string   "slug"
  end

  create_table "posts", force: true do |t|
    t.string   "title"
    t.string   "author_name"
    t.string   "slug"
    t.text     "body"
    t.string   "image_url"
    t.datetime "pubdate"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_data", force: true do |t|
    t.string   "name",            null: false
    t.string   "email",           null: false
    t.text     "profile"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_digest"
    t.string   "slug"
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "slug"
    t.string   "password_digest"
    t.string   "email"
    t.text     "profile"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
