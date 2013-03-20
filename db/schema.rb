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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130313202008) do

  create_table "genres", :force => true do |t|
    t.string   "name"
    t.integer  "tv_show_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "ratings", :force => true do |t|
    t.integer  "votes"
    t.decimal  "total_rating"
    t.string   "rating_website"
    t.integer  "rateable_id"
    t.string   "rateable_type"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "tv_episodes", :force => true do |t|
    t.integer "number"
    t.string  "title"
    t.integer "tv_season_id"
    t.date    "air_date"
  end

  create_table "tv_seasons", :force => true do |t|
    t.integer "tv_show_id"
    t.integer "number"
  end

  create_table "tv_shows", :force => true do |t|
    t.string "title"
    t.date   "year_released"
    t.date   "year_ended"
    t.text   "description"
  end

end
