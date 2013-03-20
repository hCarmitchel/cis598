class CreateTvEpisodes < ActiveRecord::Migration
  def change
    create_table :tv_episodes do |t|
      t.integer :number
      t.string :title
      t.integer :tv_season_id
      t.date :air_date

    end
  end
end
