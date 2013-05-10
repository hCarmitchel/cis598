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

ActiveRecord::Schema.define(:version => 20130508015449) do

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "genres", :force => true do |t|
    t.string  "name"
    t.integer "tv_show_id"
  end

  add_index "genres", ["tv_show_id"], :name => "index_genres_on_tv_show_id"

  create_table "ratings", :force => true do |t|
    t.integer "votes"
    t.decimal "total_rating"
    t.string  "rating_website"
    t.integer "rateable_id"
    t.string  "rateable_type"
  end

  add_index "ratings", ["rateable_id", "rateable_type"], :name => "index_ratings_on_rateable_id_and_rateable_type"

  create_table "reviews", :force => true do |t|
    t.text    "content"
    t.date    "year_reviewed"
    t.string  "title"
    t.string  "author"
    t.string  "link"
    t.decimal "rating"
    t.string  "website"
    t.integer "reviewable_id"
    t.string  "reviewable_type"
    t.integer "positives"
    t.integer "negatives"
  end

  add_index "reviews", ["reviewable_id", "reviewable_type"], :name => "index_reviews_on_reviewable_id_and_reviewable_type"

  create_table "tv_episodes", :force => true do |t|
    t.integer "number"
    t.string  "title"
    t.integer "tv_season_id"
    t.date    "air_date"
    t.string  "image"
    t.text    "description"
  end

  add_index "tv_episodes", ["tv_season_id"], :name => "index_tv_episodes_on_tv_season_id"

  create_table "tv_seasons", :force => true do |t|
    t.integer "tv_show_id"
    t.integer "number"
  end

  add_index "tv_seasons", ["tv_show_id"], :name => "index_tv_seasons_on_tv_show_id"

  create_table "tv_shows", :force => true do |t|
    t.string "title"
    t.date   "year_released"
    t.date   "year_ended"
    t.text   "description"
  end

  add_index "tv_shows", ["title", "year_released"], :name => "index_tv_shows_on_title_and_year_released"

end
