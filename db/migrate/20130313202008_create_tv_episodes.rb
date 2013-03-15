class CreateTvEpisodes < ActiveRecord::Migration
  def change
    create_table :tv_episodes do |t|
      t.integer :number
      t.integer :tv_season_id
      t.integer :tv_show_id
      t.date :date

      t.timestamps
    end
  end
end
