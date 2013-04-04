class AddIndices < ActiveRecord::Migration
  def change
  	add_index :genres, :tv_show_id
    add_index :tv_episodes, :tv_season_id
    add_index :tv_seasons, :tv_show_id
    add_index :ratings, [:rateable_id, :rateable_type]
    add_index :reviews, [:reviewable_id, :reviewable_type]
    add_index :tv_shows, [:title, :year_released]
  end
end
