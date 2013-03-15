class CreateTvShows < ActiveRecord::Migration
  def change
    create_table :tv_shows do |t|
      t.string :title
      t.date :year_released
      t.date :year_ended
      t.text :description

      t.timestamps
    end
  end
end
