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

ActiveRecord::Schema.define(version: 20140628094846) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "businesses", force: true do |t|
    t.string   "business_id"
    t.string   "name"
    t.float    "stars"
    t.integer  "review_count"
    t.string   "city"
    t.string   "state"
    t.integer  "num_prosocial"
    t.integer  "num_risktaker"
    t.integer  "num_anxious"
    t.integer  "num_passive"
    t.integer  "num_perfectionist"
    t.integer  "num_critical"
    t.integer  "num_conscientious"
    t.integer  "num_openminded"
    t.integer  "num_intuitive"
    t.integer  "num_liberal"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
